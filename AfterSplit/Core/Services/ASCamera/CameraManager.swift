
// 2.6 Camera Manager Implementation
import AVFoundation
import CoreImage
import Foundation
import SwiftUI

class CameraManager: NSObject, CameraManagerProtocol, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MultiCam Session
    var captureSession = AVCaptureMultiCamSession()
    // Properties for camera capture session
//    private let captureSession = AVCaptureSession()
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var photoOutput = AVCapturePhotoOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    
    private var frontPreviewLayer: AVCaptureVideoPreviewLayer?
    private var backPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Preview frames as UIImage
    private var frontCameraImage: UIImage?
    private var backCameraImage: UIImage?
    
    // Current filter and split style
    private(set) var currentFilter: Filter = .none
    private(set) var currentSplitStyle: SplitStyle = .straight
    
    // For async photo capture
    private var photoContinuation: CheckedContinuation<(front: Data, back: Data), Error>?
    
    // For async video recording
    private var videoRecordingURL: URL?
    private var videoRecordingContinuation: CheckedContinuation<(url: URL, duration: TimeInterval), Error>?
    
    // For video processing
    private var ciContext = CIContext()
    
    // Video and image output processing queue
    private let processingQueue = DispatchQueue(label: "com.aftersplit.processingQueue", qos: .userInitiated)
    
    // MARK: - Initialization
       override init() {
           super.init()
       }
    
    // MARK: - Setup
    
    private func requestCameraPermission() async -> Bool {
          return await withCheckedContinuation { continuation in
              AVCaptureDevice.requestAccess(for: .video) { granted in
                  continuation.resume(returning: granted)
              }
          }
      }
    

    
   
    
    func setupDualCamera() async throws {
        
        // 1. Check and request camera permissions (non-blocking)
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status != .authorized {
            let granted = await requestCameraPermission()
            if !granted {
                throw CameraError.permissionDenied
            }
            
            try await Task.detached(priority: .userInitiated) {
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                }
                
                self.captureSession.beginConfiguration()
                defer { self.captureSession.commitConfiguration() }
                //        captureSession.sessionPreset = .high
                
                // Setup inputs (front and back cameras)
                guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                      let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                    throw NSError(domain: "com.aftersplit.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find cameras"])
                }
                
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                self.backCameraInput = try AVCaptureDeviceInput(device: backCamera)
                
                guard let frontInput = self.frontCameraInput, self.captureSession.canAddInput(frontInput),
                      let backInput = self.backCameraInput, self.captureSession.canAddInput(backInput) else {
                    throw NSError(domain: "com.aftersplit.error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not add camera inputs to capture session"])
                }
                
                self.captureSession.addInput(frontInput)
                self.captureSession.addInput(backInput)
                
                // Setup outputs (photo and video)
                guard self.captureSession.canAddOutput(self.photoOutput) else {
                    throw NSError(domain: "com.aftersplit.error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not add photo output to capture session"])
                }
                self.captureSession.addOutput(self.photoOutput)
                
                guard self.captureSession.canAddOutput(self.movieOutput) else {
                    throw NSError(domain: "com.aftersplit.error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not add movie output to capture session"])
                }
                self.captureSession.addOutput(self.movieOutput)
                
                // Set maximum duration for video recording (20 minutes)
                self.movieOutput.maxRecordedDuration = CMTime(seconds: 20 * 60, preferredTimescale: 600)
                
                // Setup video preview layers
                self.setupPreviewLayers()
                
                //        captureSession.commitConfiguration()
                
                // Start the session on a background thread
                //        try await Task.detached {
                //            self.captureSession.startRunning()
            }.value
        }
    }
    
    
    
    
    private func setupPreviewLayers() {
        // Setup front camera preview layer
        frontPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        frontPreviewLayer?.videoGravity = .resizeAspectFill
        
        // Setup back camera preview layer
        backPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        backPreviewLayer?.videoGravity = .resizeAspectFill
        
        // Setup sample buffer delegate to get preview frames
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: processingQueue)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
    }
    
    // MARK: - Photo Capture
    
    func captureStillImage() async throws -> (front: Data, back: Data) {
        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation
            
            let photoSettings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoContinuation = photoContinuation else { return }
        
        if let error = error {
            photoContinuation.resume(throwing: error)
            self.photoContinuation = nil
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            photoContinuation.resume(throwing: NSError(domain: "com.aftersplit.error", code: 5, userInfo: [NSLocalizedDescriptionKey: "Could not get image data"]))
            self.photoContinuation = nil
            return
        }
        
        // For simplicity, we're using the same image data for both front and back
        // In a real implementation, you would capture from both cameras
        // Here we should apply the selected filter to the images
        let processedData = applyFilterToImageData(imageData)
        
        photoContinuation.resume(returning: (front: processedData, back: processedData))
        self.photoContinuation = nil
    }
    
    private func applyFilterToImageData(_ data: Data) -> Data {
        guard let ciFilterName = currentFilter.ciFilterName(),
              let image = UIImage(data: data),
              let ciImage = CIImage(image: image) else {
            return data
        }
        
        guard let filter = CIFilter(name: ciFilterName) else {
            return data
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let outputImage = filter.outputImage,
           let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8) ?? data
        }
        
        return data
    }
    
    // MARK: - Video Recording
    
    func startRecording() async throws {
        guard !movieOutput.isRecording else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString
        let outputURL = tempDir.appendingPathComponent("\(tempFileName).mov")
        
        // Remove any existing file at this URL
        try? FileManager.default.removeItem(at: outputURL)
        
        videoRecordingURL = outputURL
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    func stopRecording() async throws -> (url: URL, duration: TimeInterval) {
        guard movieOutput.isRecording else {
            throw NSError(domain: "com.aftersplit.error", code: 6, userInfo: [NSLocalizedDescriptionKey: "Not currently recording"])
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.videoRecordingContinuation = continuation
            movieOutput.stopRecording()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard let videoRecordingContinuation = videoRecordingContinuation else { return }
        
        if let error = error {
            videoRecordingContinuation.resume(throwing: error)
            self.videoRecordingContinuation = nil
            return
        }
        
        // Process the video with the applied filter if needed
        // This would be done with AVFoundation's video editing capabilities
 
        
        let duration = output.recordedDuration.seconds
        videoRecordingContinuation.resume(returning: (url: outputFileURL, duration: duration))
        self.videoRecordingContinuation = nil
    }
    
    // MARK: - Camera Controls
    
    func toggleCamera() async {
        // In a real implementation, this would switch between front and back cameras
        // For dual camera mode, this might toggle which camera is dominant
    }
    
    func applyFilter(_ filter: Filter) {
        currentFilter = filter
        // Update the preview with the filter
    }
    
    func setSplitStyle(_ style: SplitStyle) {
        currentSplitStyle = style
        // This would trigger UI updates in the preview
    }
    
    func getCurrentPreviewFrames() -> (front: UIImage?, back: UIImage?) {
        return (front: frontCameraImage, back: backCameraImage)
    }
    
    enum CameraError: Error, LocalizedError {
        case permissionDenied
        case unknownAuthorizationStatus
        case cameraUnavailable
        case inputConfigurationFailed
        case photoOutputFailed
        case videoOutputFailed
        case setupFailed
        
        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Camera access was denied. Please enable camera access in Settings."
            case .unknownAuthorizationStatus:
                return "Unknown camera authorization status."
            case .cameraUnavailable:
                return "Required cameras are not available."
            case .inputConfigurationFailed:
                return "Failed to configure camera inputs."
            case .photoOutputFailed:
                return "Failed to configure photo output."
            case .videoOutputFailed:
                return "Failed to configure video output."
            case .setupFailed:
                return "Failed to configure camra."
            }
        }
    }
}

//// MARK: - Sample Buffer Processing
//extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        
//        // Apply filter if needed
//        let processedImage: CIImage
//        if let filterName = currentFilter.ciFilterName(), let filter = CIFilter(name: filterName) {
//            filter.setValue(ciImage, forKey: kCIInputImageKey)
//            if let outputImage = filter.outputImage {
//                processedImage = outputImage
//            } else {
//                processedImage = ciImage
//            }
//        } else {
//            processedImage = ciImage
//        }
//        
//        // Convert to UIImage
//        if let cgImage = ciContext.createCGImage(processedImage, from: processedImage.extent) {
//            let image = UIImage(cgImage: cgImage)
//            
//            // Determine if this is from front or back camera based on connection
//            if connection.inputPorts.first?.sourceDeviceInput == frontCameraInput {
//                frontCameraImage = image
//            } else if connection.inputPorts.first?.sourceDeviceInput == backCameraInput {
//                backCameraImage = image
//            }
//        }
//    }}
//
//
// 
//    
//    // Update preview frames
//    private func startPreviewUpdates() {
//        previewUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            
//            let frames = self.cameraUseCase.getCurrentPreviewFrames()
//            
//            DispatchQueue.main.async {
//                self.frontPreview = frames.front
//                self.backPreview = frames.back
//            }
//        }
//    }
//    
//    // Capture photo
//    func capturePhoto() {
//        Task {
//            do {
//                let _ = try await cameraUseCase.capturePhoto()
//                // Photo saved, could notify user or show preview
//            } catch {
//                await MainActor.run {
//                    self.error = error
//                }
//            }
//        }
//    }
//    
//    // Toggle recording
//    func toggleRecording() {
//        Task {
//            if isRecording {
//                do {
//                    let _ = try await cameraUseCase.stopRecording()
//                    stopRecordingTimer()
//                    
//                    await MainActor.run {
//                        isRecording = false
//                        recordingTime = 0
//                    }
//                } catch {
//                    await MainActor.run {
//                        self.error = error
//                    }
//                }
//            } else {
//                do {
//                    try await cameraUseCase.startRecording()
//                    startRecordingTimer()
//                    
//                    await MainActor.run {
//                        isRecording = true
//                    }
//                } catch {
//                    await MainActor.run {
//                        self.error = error
//                    }
//                }
//            }
//        }
//    }
//    
//    // Start recording timer
//    private func startRecordingTimer() {
//        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            
//            DispatchQueue.main.async {
//                self.recordingTime += 1
//                
//                // Stop recording after 20 minutes (1200 seconds)
//                if self.recordingTime >= 1200 {
//                    self.toggleRecording()
//                }
//            }
//        }
//    }
//    
//    // Stop recording timer
//    private func stopRecordingTimer() {
//        recordingTimer?.invalidate()
//        recordingTimer = nil
//    }
//    
//    // Update filter
//    func updateFilter(_ filter: Filter) {
//        currentFilter = filter
//        cameraUseCase.applyFilter(filter)
//    }
//    
//    // Update split style
//    func updateSplitStyle(_ style: SplitStyle) {
//        splitStyle = style
//        cameraUseCase.setSplitStyle(style)
//    }
//    
//    // Toggle camera
//    func toggleCamera() {
//        Task {
//            await cameraUseCase.toggleCamera()
//        }
//    }
//    
//    // Format time for display
//    func formattedRecordingTime() -> String {
//        let minutes = Int(recordingTime) / 60
//        let seconds = Int(recordingTime) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//    
//    // Clean up
//    func cleanup() {
//        previewUpdateTimer?.invalidate()
//        recordingTimer?.invalidate()
//    }
//}
