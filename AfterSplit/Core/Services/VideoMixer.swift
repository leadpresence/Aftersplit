/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Combines video frames from two different sources with support for different split styles.
*/

import CoreMedia
import CoreVideo
import Metal
import MetalKit

class VideoMixer {
    
    var description = "Video Mixer"
    
    private(set) var isPrepared = false
    
    /// A normalized CGRect representing the position and size of the PiP in relation to the full screen video preview
    var pipFrame = CGRect.zero
    
    /// Current split style
    var splitStyle: SplitStyle = .straight
    
    private(set) var inputFormatDescription: CMFormatDescription?
    
    var outputFormatDescription: CMFormatDescription?
    
    private var outputPixelBufferPool: CVPixelBufferPool?
    
    private let metalDevice = MTLCreateSystemDefaultDevice()
    
    private var textureCache: CVMetalTextureCache?
    
    private lazy var commandQueue: MTLCommandQueue? = {
        guard let metalDevice = metalDevice else {
            return nil
        }
        
        return metalDevice.makeCommandQueue()
    }()
    
    private var computePipelineState: MTLComputePipelineState?
    
    init() {
        guard let metalDevice = metalDevice,
            let defaultLibrary = metalDevice.makeDefaultLibrary(),
            let kernelFunction = defaultLibrary.makeFunction(name: "videoMixer") else {
                print("Failed to load Metal shader")
                return
        }
        
        do {
            computePipelineState = try metalDevice.makeComputePipelineState(function: kernelFunction)
        } catch {
            print("Could not create compute pipeline state: \(error)")
        }
    }
    
    func prepare(with videoFormatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        reset()
        
        let (pool, _, formatDescription) = allocateOutputBufferPool(
            with: videoFormatDescription,
            outputRetainedBufferCountHint: outputRetainedBufferCountHint
        )
        
        if pool == nil {
            return
        }
        
        outputPixelBufferPool = pool
        outputFormatDescription = formatDescription
        inputFormatDescription = videoFormatDescription
        
        guard let metalDevice = metalDevice else {
            return
        }
        
        var metalTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, metalDevice, nil, &metalTextureCache) != kCVReturnSuccess {
            assertionFailure("Unable to allocate video mixer texture cache")
        } else {
            textureCache = metalTextureCache
        }
        
        isPrepared = true
    }
    
    func reset() {
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        textureCache = nil
        isPrepared = false
    }
    
    struct MixerParameters {
        var pipPosition: SIMD2<Float>
        var pipSize: SIMD2<Float>
        var splitStyle: UInt32
        var textureSize: SIMD2<Float>
    }
    
    func mix(frontPixelBuffer: CVPixelBuffer, backPixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        guard isPrepared,
            let outputPixelBufferPool = outputPixelBufferPool else {
                assertionFailure("Invalid state: Not prepared")
                return nil
        }
        
        var newPixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool, &newPixelBuffer)
        guard let outputPixelBuffer = newPixelBuffer else {
            print("Allocation failure: Could not get pixel buffer from pool (\(self.description))")
            return nil
        }
        
        guard let outputTexture = makeTextureFromCVPixelBuffer(pixelBuffer: outputPixelBuffer),
            let frontTexture = makeTextureFromCVPixelBuffer(pixelBuffer: frontPixelBuffer),
            let backTexture = makeTextureFromCVPixelBuffer(pixelBuffer: backPixelBuffer) else {
                return nil
        }
        
        let textureSize = SIMD2<Float>(Float(outputTexture.width), Float(outputTexture.height))
        
        // Calculate pip position and size based on split style
        let (pipPosition, pipSize): (SIMD2<Float>, SIMD2<Float>) = {
            switch splitStyle {
            case .straight:
                // For straight, we don't use pip positioning
                return (SIMD2<Float>(0, 0), SIMD2<Float>(0, 0))
            case .circular, .corner:
                // Use normalized pip frame
                let pos = SIMD2<Float>(
                    Float(pipFrame.origin.x) * textureSize.x,
                    Float(pipFrame.origin.y) * textureSize.y
                )
                let size = SIMD2<Float>(
                    Float(pipFrame.size.width) * textureSize.x,
                    Float(pipFrame.size.height) * textureSize.y
                )
                return (pos, size)
            case .diagonal:
                // For diagonal, we don't use pip positioning
                return (SIMD2<Float>(0, 0), SIMD2<Float>(0, 0))
            }
        }()
        
        let splitStyleValue: UInt32 = {
            switch splitStyle {
            case .straight: return 0
            case .diagonal: return 1
            case .circular: return 2
            case .corner: return 3
            }
        }()
        
        var parameters = MixerParameters(
            pipPosition: pipPosition,
            pipSize: pipSize,
            splitStyle: splitStyleValue,
            textureSize: textureSize
        )
        
        // Set up command queue, buffer, and encoder
        guard let commandQueue = commandQueue,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
            let computePipelineState = computePipelineState else {
                print("Failed to create Metal command encoder")
                
                if let textureCache = textureCache {
                    CVMetalTextureCacheFlush(textureCache, 0)
                }
                
                return nil
        }
        
        commandEncoder.label = "Video Mixer"
        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.setTexture(frontTexture, index: 0)
        commandEncoder.setTexture(backTexture, index: 1)
        commandEncoder.setTexture(outputTexture, index: 2)
        withUnsafeMutablePointer(to: &parameters) { parametersRawPointer in
            commandEncoder.setBytes(parametersRawPointer, length: MemoryLayout<MixerParameters>.size, index: 0)
        }
        
        // Set up thread groups
        let width = computePipelineState.threadExecutionWidth
        let height = computePipelineState.maxTotalThreadsPerThreadgroup / width
        let threadsPerThreadgroup = MTLSizeMake(width, height, 1)
        let threadgroupsPerGrid = MTLSize(
            width: (outputTexture.width + width - 1) / width,
            height: (outputTexture.height + height - 1) / height,
            depth: 1
        )
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return outputPixelBuffer
    }
    
    private func makeTextureFromCVPixelBuffer(pixelBuffer: CVPixelBuffer) -> MTLTexture? {
        guard let textureCache = textureCache else {
            print("No texture cache")
            return nil
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // Create a Metal texture from the image buffer
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &cvTextureOut
        )
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else {
            print("Video mixer failed to create preview texture")
            
            CVMetalTextureCacheFlush(textureCache, 0)
            return nil
        }
        
        return texture
    }
    
    // MARK: - Buffer Pool Allocation
    
    private func allocateOutputBufferPool(
        with inputFormatDescription: CMFormatDescription,
        outputRetainedBufferCountHint: Int
    ) -> (
        outputBufferPool: CVPixelBufferPool?,
        outputColorSpace: CGColorSpace?,
        outputFormatDescription: CMFormatDescription?
    ) {
        let inputMediaSubType = CMFormatDescriptionGetMediaSubType(inputFormatDescription)
        if inputMediaSubType != kCVPixelFormatType_Lossy_32BGRA &&
            inputMediaSubType != kCVPixelFormatType_Lossless_32BGRA &&
            inputMediaSubType != kCVPixelFormatType_32BGRA {
            assertionFailure("Invalid input pixel buffer type \(inputMediaSubType)")
            return (nil, nil, nil)
        }
        
        let inputDimensions = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
        var pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: UInt(inputMediaSubType),
            kCVPixelBufferWidthKey as String: Int(inputDimensions.width),
            kCVPixelBufferHeightKey as String: Int(inputDimensions.height),
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        // Get pixel buffer attributes and color space from the input format description
        var cgColorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        if let inputFormatDescriptionExtension = CMFormatDescriptionGetExtensions(inputFormatDescription) as Dictionary? {
            let colorPrimaries = inputFormatDescriptionExtension[kCVImageBufferColorPrimariesKey]
            
            if let colorPrimaries = colorPrimaries {
                var colorSpaceProperties: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: colorPrimaries]
                
                if let yCbCrMatrix = inputFormatDescriptionExtension[kCVImageBufferYCbCrMatrixKey] {
                    colorSpaceProperties[kCVImageBufferYCbCrMatrixKey as String] = yCbCrMatrix
                }
                
                if let transferFunction = inputFormatDescriptionExtension[kCVImageBufferTransferFunctionKey] {
                    colorSpaceProperties[kCVImageBufferTransferFunctionKey as String] = transferFunction
                }
                
                pixelBufferAttributes[kCVBufferPropagatedAttachmentsKey as String] = colorSpaceProperties
            }
            
            if let cvColorspace = inputFormatDescriptionExtension[kCVImageBufferCGColorSpaceKey],
                CFGetTypeID(cvColorspace) == CGColorSpace.typeID {
                cgColorSpace = (cvColorspace as! CGColorSpace)
            } else if (colorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String) {
                cgColorSpace = CGColorSpace(name: CGColorSpace.displayP3)
            }
        }
        
        // Create a pixel buffer pool with the same pixel attributes as the input format description.
        let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: outputRetainedBufferCountHint]
        var cvPixelBufferPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(
            kCFAllocatorDefault,
            poolAttributes as NSDictionary?,
            pixelBufferAttributes as NSDictionary?,
            &cvPixelBufferPool
        )
        guard let pixelBufferPool = cvPixelBufferPool else {
            assertionFailure("Allocation failure: Could not allocate pixel buffer pool.")
            return (nil, nil, nil)
        }
        
        preallocateBuffers(pool: pixelBufferPool, allocationThreshold: outputRetainedBufferCountHint)
        
        // Get the output format description
        var pixelBuffer: CVPixelBuffer?
        var outputFormatDescription: CMFormatDescription?
        let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: outputRetainedBufferCountHint] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(
            kCFAllocatorDefault,
            pixelBufferPool,
            auxAttributes,
            &pixelBuffer
        )
        if let pixelBuffer = pixelBuffer {
            CMVideoFormatDescriptionCreateForImageBuffer(
                allocator: kCFAllocatorDefault,
                imageBuffer: pixelBuffer,
                formatDescriptionOut: &outputFormatDescription
            )
        }
        pixelBuffer = nil
        
        return (pixelBufferPool, cgColorSpace, outputFormatDescription)
    }
    
    private func preallocateBuffers(pool: CVPixelBufferPool, allocationThreshold: Int) {
        var pixelBuffers = [CVPixelBuffer]()
        var error: CVReturn = kCVReturnSuccess
        let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: allocationThreshold] as NSDictionary
        var pixelBuffer: CVPixelBuffer?
        while error == kCVReturnSuccess {
            error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(
                kCFAllocatorDefault,
                pool,
                auxAttributes,
                &pixelBuffer
            )
            if let pixelBuffer = pixelBuffer {
                pixelBuffers.append(pixelBuffer)
            }
            pixelBuffer = nil
        }
        pixelBuffers.removeAll()
    }
}

