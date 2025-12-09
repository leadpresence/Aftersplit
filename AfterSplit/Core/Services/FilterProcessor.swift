//
//  FilterProcessor.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import CoreImage
import CoreVideo
import UIKit
import Metal

class FilterProcessor {
    private let context: CIContext
    private var pixelBufferPoolCache: [String: CVPixelBufferPool] = [:]
    private let cacheQueue = DispatchQueue(label: "com.aftersplit.filterProcessor.cache")
    
    init() {
        // Use Metal for better performance if available
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: metalDevice)
        } else {
            context = CIContext()
        }
    }
    
    func applyFilter(_ filter: Filter, to pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        guard filter != .none else {
            return pixelBuffer
        }
        
        guard let ciFilterName = filter.ciFilterName(),
              let ciFilter = CIFilter(name: ciFilterName) else {
            return pixelBuffer
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Set additional parameters for specific filters
        switch filter {
        case .vibrant:
            ciFilter.setValue(1.0, forKey: kCIInputAmountKey)
        default:
            break
        }
        
        guard let outputImage = ciFilter.outputImage else {
            return pixelBuffer
        }
        
        // Render to new pixel buffer
        guard let pool = getOrCreatePixelBufferPool(for: pixelBuffer) else {
            return pixelBuffer
        }
        
        var outputPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(
            kCFAllocatorDefault,
            pool,
            &outputPixelBuffer
        )
        
        guard status == kCVReturnSuccess,
              let outputBuffer = outputPixelBuffer else {
            return pixelBuffer
        }
        
        context.render(outputImage, to: outputBuffer)
        
        return outputBuffer
    }
    
    func applyFilter(_ filter: Filter, to image: UIImage) -> UIImage? {
        guard filter != .none else {
            return image
        }
        
        guard let ciFilterName = filter.ciFilterName(),
              let ciFilter = CIFilter(name: ciFilterName),
              let ciImage = CIImage(image: image) else {
            return image
        }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // Set additional parameters for specific filters
        switch filter {
        case .vibrant:
            ciFilter.setValue(1.0, forKey: kCIInputAmountKey)
        default:
            break
        }
        
        guard let outputImage = ciFilter.outputImage else {
            return image
        }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func getOrCreatePixelBufferPool(for pixelBuffer: CVPixelBuffer) -> CVPixelBufferPool? {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let cacheKey = "\(width)x\(height)_\(pixelFormat)"
        
        return cacheQueue.sync {
            if let cachedPool = pixelBufferPoolCache[cacheKey] {
                return cachedPool
            }
            
            let attributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ]
            
            let poolAttributes: [String: Any] = [
                kCVPixelBufferPoolMinimumBufferCountKey as String: 3
            ]
            
            var pool: CVPixelBufferPool?
            let status = CVPixelBufferPoolCreate(
                kCFAllocatorDefault,
                poolAttributes as NSDictionary?,
                attributes as NSDictionary?,
                &pool
            )
            
            guard status == kCVReturnSuccess, let createdPool = pool else {
                return nil
            }
            
            pixelBufferPoolCache[cacheKey] = createdPool
            return createdPool
        }
    }
}

