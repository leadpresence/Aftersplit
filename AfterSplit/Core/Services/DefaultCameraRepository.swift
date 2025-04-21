//
//  DefaultCameraRepository.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI
import AVFoundation

class DefaultCameraRepository: CameraRepositorySec {
    private var multiCamSession: AVCaptureMultiCamSession?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var frontPhotoOutput: AVCapturePhotoOutput?
    private var backPhotoOutput: AVCapturePhotoOutput?
    private var frontMovieOutput: AVCaptureMovieFileOutput?
    private var backMovieOutput: AVCaptureMovieFileOutput?
    
    private var isRecording = false
    private var frontVideoURL: URL?
    private var backVideoURL: URL?
    
    private let photoCaptureSemaphore = DispatchSemaphore(value: 0)
    private let videoCaptureSemaphore = DispatchSemaphore(value: 0)
    
    private var frontCapturePhotoPromise: ((Result<URL, Error>) -> Void)?
    private var backCapturePhotoPromise: ((Result<URL, Error>) -> Void)?
    
    init() {}
    
    func setupCaptureSession() throws {
        // Check for device compatibility first
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            throw CameraError.multiCamNotSupported
        }
        
        // Create the capture session
        let session = AVCaptureMultiCamSession()
        
        // Configure cameras
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.cameraUnavailable
        }
        
        do {
            // Configure inputs
            let frontInput = try AVCaptureDeviceInput(device: frontCamera)
            let backInput = try AVCaptureDeviceInput(device: backCamera)
            
            // Configure outputs for photos
            let frontPhotoOutput = AVCapturePhotoOutput()
            let backPhotoOutput = AVCapturePhotoOutput()
            
            // Configure outputs for videos
            let frontMovieOutput = AVCaptureMovieFileOutput()
            let backMovieOutput = AVCaptureMovieFileOutput()
            
            // Configure session with no connections
            session.beginConfiguration()
            
            // Add inputs
            if session.canAddInput(frontInput) {
                session.addInputWithNoConnections(frontInput)
            } else {
                throw CameraError.inputError
            }
            
            if session.canAddInput(backInput) {
                session.addInputWithNoConnections(backInput)
            } else {
                throw CameraError.inputError
            }
            
            // Add outputs
            if session.canAddOutput(frontPhotoOutput) {
                session.addOutputWithNoConnections(frontPhotoOutput)
            } else {
                throw CameraError.outputError
            }
            
            if session.canAddOutput(backPhotoOutput) {
                session.addOutputWithNoConnections(backPhotoOutput)
            } else {
                throw CameraError.outputError
            }
            
            if session.canAddOutput(frontMovieOutput) {
                session.addOutputWithNoConnections(frontMovieOutput)
            } else {
                throw CameraError.outputError
            }
            
            if session.canAddOutput(backMovieOutput) {
                session.addOutputWithNoConnections(backMovieOutput)
            } else {
                throw CameraError.outputError
            }
            
            // Configure connections
            // For front camera
            guard let frontVideoPort = frontInput.ports(for: .video, sourceDeviceType: frontCamera.deviceType, sourceDevicePosition: frontCamera.position).first else {
                throw CameraError.portError
            }
            
            // Front camera to photo output connection
            let frontPhotoConnection = AVCaptureConnection(inputPorts: [frontVideoPort], output: frontPhotoOutput)
            if session.canAddConnection(frontPhotoConnection) {
                session.addConnection(frontPhotoConnection)
            } else {
                throw CameraError.connectionError
            }
            
            // Front camera to movie output connection
            let frontMovieConnection = AVCaptureConnection(inputPorts: [frontVideoPort], output: frontMovieOutput)
            if session.canAddConnection(frontMovieConnection) {
                session.addConnection(frontMovieConnection)
            } else {
                throw CameraError.connectionError
            }
            
            // For back camera
            guard let backVideoPort = backInput.ports(for: .video, sourceDeviceType: backCamera.deviceType, sourceDevicePosition: backCamera.position).first else {
                throw CameraError.portError
            }
            
            // Back camera to photo output connection
            let backPhotoConnection = AVCaptureConnection(inputPorts: [backVideoPort], output: backPhotoOutput)
            if session.canAddConnection(backPhotoConnection) {
                session.addConnection(backPhotoConnection)
            } else {
                throw CameraError.connectionError
            }
            
            // Back camera to movie output connection
            let backMovieConnection = AVCaptureConnection(inputPorts: [backVideoPort], output: backMovieOutput)
            if session.canAddConnection(backMovieConnection) {
                session.addConnection(backMovieConnection)
            } else {
                throw CameraError.connectionError
            }
            
            // Check hardware cost to ensure session is runnable
            if session.hardwareCost <= 1.0 {
                session.commitConfiguration()
                
                // Save references
                self.multiCamSession = session
                self.frontCameraInput = frontInput
                self.backCameraInput = backInput
                self.frontPhotoOutput = frontPhotoOutput
                self.backPhotoOutput = backPhotoOutput
                self.frontMovieOutput = frontMovieOutput
                self.backMovieOutput = backMovieOutput
            } else {
                throw CameraError.hardwareCostTooHigh
            }
        } catch {
            throw error
        }
    }
    
    func startSession() {
        guard let session = multiCamSession else { return }
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
    
    func stopSession() {
        guard let session = multiCamSession else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func capturePhoto() async throws -> [URL] {
        guard let frontOutput = frontPhotoOutput,
              let backOutput = backPhotoOutput else {
            throw CameraError.outputError
        }
        
        // Create front camera photo promise
        let frontPhotoPromise = Task { () -> URL in
            return try await withCheckedThrowingContinuation { continuation in
                self.frontCapturePhotoPromise = continuation.resume
                
                let photoSettings = AVCapturePhotoSettings()
                let photoCaptureDelegate = PhotoCaptureDelegate(
                    willCapturePhotoAnimation: {},
                    didFinishProcessingPhoto: { data in
                        guard let data = data else {
                            continuation.resume(throwing: CameraError.processingError)
                            return
                        }
                        
                        do {
                            // Generate a unique filename
                            let fileName = "front_photo_\(UUID().uuidString).jpg"
                            let fileURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                            
                            // Write the photo data to the file
                            try data.write(to: fileURL)
                            continuation.resume(returning: fileURL)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                )
                
                frontOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
            }
        }
        
        // Create back camera photo promise
        let backPhotoPromise = Task { () -> URL in
            return try await withCheckedThrowingContinuation { continuation in
                self.backCapturePhotoPromise = continuation.resume
                
                let photoSettings = AVCapturePhotoSettings()
                let photoCaptureDelegate = PhotoCaptureDelegate(
                    willCapturePhotoAnimation: {},
                    didFinishProcessingPhoto: { data in
                        guard let data = data else {
                            continuation.resume(throwing: CameraError.processingError)
                            return
                        }
                        
                        do {
                            // Generate a unique filename
                            let fileName = "back_photo_\(UUID().uuidString).jpg"
                            let fileURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
                            
                            // Write the photo data to the file
                            try data.write(to: fileURL)
                            continuation.resume(returning: fileURL)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                )
                
                backOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
            }
        }
        
        // Wait for both photos to complete
        let frontURL = try await frontPhotoPromise.value
        let backURL = try await backPhotoPromise.value
        
        // Combine the two photos
        let combinedURL = try await combinePhotos(frontURL: frontURL, backURL: backURL)
        
        return [frontURL, backURL, combinedURL]
    }
    
    func startRecording() async throws {
        guard let frontOutput = frontMovieOutput,
              let backOutput = backMovieOutput,
              !isRecording else {
            throw CameraError.alreadyRecording
        }
        
        // Create unique file URLs for recording
        let frontFileName = "front_video_\(UUID().uuidString).mov"
        let backFileName = "back_video_\(UUID().uuidString).mov"
        
        frontVideoURL = getDocumentsDirectory().appendingPathComponent(frontFileName)
        backVideoURL = getDocumentsDirectory().appendingPathComponent(backFileName)
        
        guard let frontVideoURL = frontVideoURL,
              let backVideoURL = backVideoURL else {
            throw CameraError.fileError
        }
        
        let frontVideoDelegate = VideoRecordingDelegate(
            finishedRecording: { success, error in
                // Handle recording completion
                if !success {
                    print("Error recording front video: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        )
        
        let backVideoDelegate = VideoRecordingDelegate(
            finishedRecording: { success, error in
                // Handle recording completion
                if !success {
                    print("Error recording back video: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        )
        
        // Start recording with both cameras
        frontOutput.startRecording(to: frontVideoURL, recordingDelegate: frontVideoDelegate)
        backOutput.startRecording(to: backVideoURL, recordingDelegate: backVideoDelegate)
        
        isRecording = true
    }
    
    func stopRecording() async throws -> [URL] {
        guard let frontOutput = frontMovieOutput,
              let backOutput = backMovieOutput,
              isRecording,
              let frontVideoURL = frontVideoURL,
              let backVideoURL = backVideoURL else {
            throw CameraError.notRecording
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // Create a dispatch group to wait for both recordings to finish
            let group = DispatchGroup()
            
            group.enter()
            if frontOutput.isRecording {
                frontOutput.stopRecording()
            }
            group.leave()
            
            group.enter()
            if backOutput.isRecording {
                backOutput.stopRecording()
            }
            group.leave()
            
            group.notify(queue: .main) {
                // After both recordings have stopped
                self.isRecording = false
                
                // Combine the two videos (this would be a complex operation requiring AVFoundation)
                Task {
                    do {
                        let combinedURL = try await self.combineVideos(frontURL: frontVideoURL, backURL: backVideoURL)
                        continuation.resume(returning: [frontVideoURL, backVideoURL, combinedURL])
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func getAllSavedMedia() -> [MediaItem] {
        do {
            let fileManager = FileManager.default
            let documentsURL = getDocumentsDirectory()
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
            
            return fileURLs.compactMap { url in
                guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                      let modificationDate = attributes[.modificationDate] as? Date else {
                    return nil
                }
                
                let isVideo = url.pathExtension.lowercased() == "mov"
                let isPhoto = ["jpg", "jpeg", "png"].contains(url.pathExtension.lowercased())
                
                if isPhoto {
                    return MediaItem(
                        id: UUID(),
                        url: url,
                        thumbnailUrl: url,
                        type: .photo,
                        timestamp: modificationDate
                    )
                } else if isVideo {
                    // For videos, we might want to generate a thumbnail
                    // This is a simplified version; in a real app, you'd want to generate actual thumbnails
                    return MediaItem(
                        id: UUID(),
                        url: url,
                        thumbnailUrl: nil,
                        type: .video,
                        timestamp: modificationDate
                    )
                }
                
                return nil
            }.sorted(by: { $0.timestamp > $1.timestamp })
        } catch {
            print("Error getting saved media: \(error)")
            return []
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String) throws -> URL {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CameraError.processingError
        }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        try imageData.write(to: fileURL)
        return fileURL
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    // Helper methods for combining media
    private func combinePhotos(frontURL: URL, backURL: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    guard let frontImage = UIImage(contentsOfFile: frontURL.path),
                          let backImage = UIImage(contentsOfFile: backURL.path) else {
                        continuation.resume(throwing: CameraError.processingError)
                        return
                    }
                    
                    // Create a combined image (side by side)
                    let size = CGSize(
                        width: frontImage.size.width + backImage.size.width,
                        height: max(frontImage.size.height, backImage.size.height)
                    )
                    
                    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                    
                    // Draw front image on the left side
                    frontImage.draw(in: CGRect(
                        x: 0,
                        y: 0,
                        width: frontImage.size.width,
                        height: frontImage.size.height
                    ))
                    
                    // Draw back image on the right side
                    backImage.draw(in: CGRect(
                        x: frontImage.size.width,
                        y: 0,
                        width: backImage.size.width,
                        height: backImage.size.height
                    ))
                    
                    guard let combinedImage = UIGraphicsGetImageFromCurrentImageContext() else {
                        UIGraphicsEndImageContext()
                        continuation.resume(throwing: CameraError.processingError)
                        return
                    }
                    
                    UIGraphicsEndImageContext()
                    
                    // Save the combined image
                    let combinedFileName = "combined_photo_\(UUID().uuidString).jpg"
                    let combinedURL = self.getDocumentsDirectory().appendingPathComponent(combinedFileName)
                    
                    if let combinedData = combinedImage.jpegData(compressionQuality: 0.8) {
                        try combinedData.write(to: combinedURL)
                        continuation.resume(returning: combinedURL)
                    } else {
                        continuation.resume(throwing: CameraError.processingError)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func combineVideos(frontURL: URL, backURL: URL) async throws -> URL {
        // In a real implementation, you would use AVFoundation to combine videos
        // This is a complex task that would involve AVComposition, AVVideoCompositionLayerInstruction,
        // AVVideoCompositionInstruction, and AVAssetExportSession
        
        // For now, we'll just return a placeholder URL to represent the combined video
        let combinedFileName = "combined_video_\(UUID().uuidString).mov"
        let combinedURL = getDocumentsDirectory().appendingPathComponent(combinedFileName)
        
        // In a real implementation, you would combine the videos and save to combinedURL
        // This is just a placeholder
        // We're copying the front video as a demonstration
        try FileManager.default.copyItem(at: frontURL, to: combinedURL)
        
        return combinedURL
    }
}
