//
//  DefaultCameraRepository.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI
import AVFoundation
import CoreImage
import Metal

class DefaultCameraRepository: CameraRepositorySec, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    private var multiCamSession: AVCaptureMultiCamSession?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var backCameraInput: AVCaptureDeviceInput?
    private var frontPhotoOutput: AVCapturePhotoOutput?
    private var backPhotoOutput: AVCapturePhotoOutput?
    private var frontMovieOutput: AVCaptureMovieFileOutput?
    private var backMovieOutput: AVCaptureMovieFileOutput?
    
    // Preview layers
    private var frontPreviewLayer: AVCaptureVideoPreviewLayer?
    private var backPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Video data outputs for real-time processing
    private var frontVideoDataOutput: AVCaptureVideoDataOutput?
    private var backVideoDataOutput: AVCaptureVideoDataOutput?
    
    // Audio input and output
    private var microphoneInput: AVCaptureDeviceInput?
    private var audioDataOutput: AVCaptureAudioDataOutput?
    
    // Video mixer and recorder
    private var videoMixer: VideoMixer?
    private var movieRecorder: MovieRecorder?
    private var filterProcessor: FilterProcessor?
    
    // State
    private var currentSplitStyle: SplitStyle = .straight
    private var currentFilter: Filter = .none
    
    // Sample buffer tracking
    private var frontPixelBuffer: CVPixelBuffer?
    private var backPixelBuffer: CVPixelBuffer?
    private var renderingEnabled = true
    
    // Session observers
    private var keyValueObservations = [NSKeyValueObservation]()
    private var sessionRunningContext = 0
    
    private let dataOutputQueue = DispatchQueue(label: "com.aftersplit.dataOutputQueue")
    
    private var isRecording = false
    private var frontVideoURL: URL?
    private var backVideoURL: URL?
    
    private let photoCaptureSemaphore = DispatchSemaphore(value: 0)
    private let videoCaptureSemaphore = DispatchSemaphore(value: 0)
    
    private var frontCapturePhotoPromise: ((Result<URL, Error>) -> Void)?
    private var backCapturePhotoPromise: ((Result<URL, Error>) -> Void)?
    
    init() {
        videoMixer = VideoMixer()
        filterProcessor = FilterProcessor()
    }
    
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
            
            // Configure video data outputs for real-time processing and preview
            let frontVideoDataOutput = AVCaptureVideoDataOutput()
            let backVideoDataOutput = AVCaptureVideoDataOutput()
            
            // Set pixel format for video data outputs
            if frontVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
                frontVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
            } else if frontVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
                frontVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
            } else {
                frontVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            }
            
            if backVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossy_32BGRA) {
                backVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossy_32BGRA)]
            } else if backVideoDataOutput.availableVideoPixelFormatTypes.contains(kCVPixelFormatType_Lossless_32BGRA) {
                backVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_Lossless_32BGRA)]
            } else {
                backVideoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            }
            
            frontVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
            backVideoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
            
            // Create preview layers
            let frontPreviewLayer = AVCaptureVideoPreviewLayer()
            let backPreviewLayer = AVCaptureVideoPreviewLayer()
            frontPreviewLayer.videoGravity = .resizeAspectFill
            backPreviewLayer.videoGravity = .resizeAspectFill
            
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
            
            // Add video data outputs
            if session.canAddOutput(frontVideoDataOutput) {
                session.addOutputWithNoConnections(frontVideoDataOutput)
            } else {
                throw CameraError.outputError
            }
            
            if session.canAddOutput(backVideoDataOutput) {
                session.addOutputWithNoConnections(backVideoDataOutput)
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
            
            // Front camera to video data output connection
            let frontVideoDataConnection = AVCaptureConnection(inputPorts: [frontVideoPort], output: frontVideoDataOutput)
            if session.canAddConnection(frontVideoDataConnection) {
                session.addConnection(frontVideoDataConnection)
                frontVideoDataConnection.videoOrientation = .portrait
                frontVideoDataConnection.automaticallyAdjustsVideoMirroring = false
                frontVideoDataConnection.isVideoMirrored = true
            } else {
                throw CameraError.connectionError
            }
            
            // Front camera to preview layer connection
            let frontPreviewConnection = AVCaptureConnection(inputPort: frontVideoPort, videoPreviewLayer: frontPreviewLayer)
            if session.canAddConnection(frontPreviewConnection) {
                session.addConnection(frontPreviewConnection)
                frontPreviewConnection.automaticallyAdjustsVideoMirroring = false
                frontPreviewConnection.isVideoMirrored = true
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
            
            // Back camera to video data output connection
            let backVideoDataConnection = AVCaptureConnection(inputPorts: [backVideoPort], output: backVideoDataOutput)
            if session.canAddConnection(backVideoDataConnection) {
                session.addConnection(backVideoDataConnection)
                backVideoDataConnection.videoOrientation = .portrait
            } else {
                throw CameraError.connectionError
            }
            
            // Back camera to preview layer connection
            let backPreviewConnection = AVCaptureConnection(inputPort: backVideoPort, videoPreviewLayer: backPreviewLayer)
            if session.canAddConnection(backPreviewConnection) {
                session.addConnection(backPreviewConnection)
            } else {
                throw CameraError.connectionError
            }
            
            // Configure microphone input
            guard let microphone = AVCaptureDevice.default(for: .audio) else {
                throw CameraError.cameraUnavailable
            }
            
            let microphoneInput = try AVCaptureDeviceInput(device: microphone)
            if session.canAddInput(microphoneInput) {
                session.addInputWithNoConnections(microphoneInput)
            } else {
                throw CameraError.inputError
            }
            
            // Configure audio data output
            let audioDataOutput = AVCaptureAudioDataOutput()
            if session.canAddOutput(audioDataOutput) {
                session.addOutputWithNoConnections(audioDataOutput)
            } else {
                throw CameraError.outputError
            }
            
            // Find microphone audio port
            guard let microphoneAudioPort = microphoneInput.ports(for: .audio, sourceDeviceType: microphone.deviceType, sourceDevicePosition: .unspecified).first else {
                throw CameraError.portError
            }
            
            // Connect microphone to audio output
            let audioConnection = AVCaptureConnection(inputPorts: [microphoneAudioPort], output: audioDataOutput)
            if session.canAddConnection(audioConnection) {
                session.addConnection(audioConnection)
            } else {
                throw CameraError.connectionError
            }
            
            audioDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
            self.microphoneInput = microphoneInput
            self.audioDataOutput = audioDataOutput
            
            // Check hardware cost to ensure session is runnable
            session.commitConfiguration()
            
            // Check system cost and optimize if needed
            checkSystemCost(session: session)
            
            // Save references
            self.multiCamSession = session
            self.frontCameraInput = frontInput
            self.backCameraInput = backInput
            self.frontPhotoOutput = frontPhotoOutput
            self.backPhotoOutput = backPhotoOutput
            self.frontMovieOutput = frontMovieOutput
            self.backMovieOutput = backMovieOutput
            self.frontVideoDataOutput = frontVideoDataOutput
            self.backVideoDataOutput = backVideoDataOutput
            self.frontPreviewLayer = frontPreviewLayer
            self.backPreviewLayer = backPreviewLayer
        } catch {
            throw error
        }
    }
    
    func startSession() {
        guard let session = multiCamSession else { return }
        if !session.isRunning {
            addSessionObservers()
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
    
    func stopSession() {
        guard let session = multiCamSession else { return }
        if session.isRunning {
            removeSessionObservers()
            session.stopRunning()
        }
    }
    
    // MARK: - Session Observers
    
    private func addSessionObservers() {
        guard let session = multiCamSession else { return }
        
        // Observe session running state
        let sessionRunningObservation = session.observe(\.isRunning, options: .new) { [weak self] session, change in
            guard let isRunning = change.newValue else { return }
            print("Session running state changed: \(isRunning)")
        }
        keyValueObservations.append(sessionRunningObservation)
        
        // Observe system pressure state
        if let backCameraInput = backCameraInput {
            let pressureObservation = observe(\.backCameraInput?.device.systemPressureState, options: .new) { [weak self] _, change in
                guard let systemPressureState = change.newValue as? AVCaptureDevice.SystemPressureState else { return }
                self?.handleSystemPressureState(systemPressureState)
            }
            keyValueObservations.append(pressureObservation)
        }
        
        // Add notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: session
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: session
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: session
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func removeSessionObservers() {
        for observation in keyValueObservations {
            observation.invalidate()
        }
        keyValueObservations.removeAll()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        if error.code == .mediaServicesWereReset {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self, let session = self.multiCamSession else { return }
                if session.isRunning {
                    session.startRunning()
                }
            }
        }
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted: \(reason)")
            
            if reason == .videoDeviceInUseByAnotherClient {
                // Handle device in use
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Handle device not available
            }
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
    }
    
    @objc private func didEnterBackground(notification: NSNotification) {
        dataOutputQueue.async { [weak self] in
            self?.renderingEnabled = false
            self?.videoMixer?.reset()
            self?.frontPixelBuffer = nil
            self?.backPixelBuffer = nil
        }
    }
    
    @objc private func willEnterForeground(notification: NSNotification) {
        dataOutputQueue.async { [weak self] in
            self?.renderingEnabled = true
        }
    }
    
    private func handleSystemPressureState(_ systemPressureState: AVCaptureDevice.SystemPressureState) {
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if movieRecorder == nil || movieRecorder?.isRecording == false {
                do {
                    try backCameraInput?.device.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    backCameraInput?.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20)
                    backCameraInput?.device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 15)
                    backCameraInput?.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to system pressure level.")
        }
    }
    
    deinit {
        removeSessionObservers()
        stopSession()
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
        guard !isRecording,
              let frontVideoDataOutput = frontVideoDataOutput,
              let backVideoDataOutput = backVideoDataOutput else {
            throw CameraError.alreadyRecording
        }
        
        // Create output file URL
        let fileName = "combined_video_\(UUID().uuidString).mov"
        let outputURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        // Get video and audio settings from outputs
        guard let videoSettings = frontVideoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov) as? [String: Any] else {
            throw CameraError.processingError
        }
        
        var audioSettings: [String: Any] = [:]
        if let audioOutput = audioDataOutput {
            audioSettings = audioOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov) as? [String: Any] ?? [:]
        }
        
        // Get video transform
        guard let videoConnection = frontVideoDataOutput.connection(with: .video) else {
            throw CameraError.connectionError
        }
        
        let deviceOrientation = UIDevice.current.orientation
        let videoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) ?? .portrait
        let videoTransform = videoConnection.videoOrientationTransform(relativeTo: videoOrientation)
        
        // Create movie recorder
        let recorder = MovieRecorder(
            audioSettings: audioSettings,
            videoSettings: videoSettings,
            videoTransform: videoTransform
        )
        
        recorder.startRecording(to: outputURL)
        self.movieRecorder = recorder
        self.isRecording = true
    }
    
    func stopRecording() async throws -> [URL] {
        guard isRecording,
              let recorder = movieRecorder else {
            throw CameraError.notRecording
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            recorder.stopRecording { url in
                self.isRecording = false
                self.movieRecorder = nil
                
                if let url = url {
                    continuation.resume(returning: [url])
                } else {
                    continuation.resume(throwing: CameraError.processingError)
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
    
    // MARK: - Preview Layer Access
    
    func getFrontPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return frontPreviewLayer
    }
    
    func getBackPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return backPreviewLayer
    }
    
    // MARK: - Video Data Output Delegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard renderingEnabled else { return }
        
        if let videoDataOutput = output as? AVCaptureVideoDataOutput {
            processVideoSampleBuffer(sampleBuffer, fromOutput: videoDataOutput)
        }
    }
    
    // MARK: - Audio Data Output Delegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let audioDataOutput = output as? AVCaptureAudioDataOutput {
            processAudioSampleBuffer(sampleBuffer)
        }
    }
    
    // MARK: - Sample Buffer Processing
    
    private func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer, fromOutput videoDataOutput: AVCaptureVideoDataOutput) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Apply filter if needed
        var processedBuffer: CVPixelBuffer = pixelBuffer
        if currentFilter != .none, let filterProcessor = filterProcessor {
            if let filtered = filterProcessor.applyFilter(currentFilter, to: pixelBuffer) {
                processedBuffer = filtered
            }
        }
        
        // Store pixel buffer based on which camera it came from
        if videoDataOutput == frontVideoDataOutput {
            frontPixelBuffer = processedBuffer
        } else if videoDataOutput == backVideoDataOutput {
            backPixelBuffer = processedBuffer
        }
        
        // If we have both buffers, mix them
        if let frontBuffer = frontPixelBuffer,
           let backBuffer = backPixelBuffer,
           let videoMixer = videoMixer {
            
            // Prepare mixer if needed
            if !videoMixer.isPrepared {
                if let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                    videoMixer.prepare(with: formatDescription, outputRetainedBufferCountHint: 3)
                }
            }
            
            // Update mixer split style
            videoMixer.splitStyle = currentSplitStyle
            
            // Mix the buffers
            if let mixedBuffer = videoMixer.mix(frontPixelBuffer: frontBuffer, backPixelBuffer: backBuffer) {
                // Create sample buffer from mixed pixel buffer
                if let mixedSampleBuffer = createSampleBuffer(from: mixedBuffer, with: sampleBuffer) {
                    // Record if recording
                    if isRecording, let recorder = movieRecorder {
                        recorder.recordVideo(sampleBuffer: mixedSampleBuffer)
                    }
                }
            }
        }
    }
    
    private func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if isRecording, let recorder = movieRecorder {
            recorder.recordAudio(sampleBuffer: sampleBuffer)
        }
    }
    
    private func createSampleBuffer(from pixelBuffer: CVPixelBuffer, with originalSampleBuffer: CMSampleBuffer) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo(
            duration: CMSampleBufferGetDuration(originalSampleBuffer),
            presentationTimeStamp: CMSampleBufferGetPresentationTimeStamp(originalSampleBuffer),
            decodeTimeStamp: CMSampleBufferGetDecodeTimeStamp(originalSampleBuffer)
        )
        
        var formatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &formatDescription)
        
        guard let formatDesc = formatDescription else {
            return nil
        }
        
        let err = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDesc,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )
        
        if sampleBuffer == nil {
            print("Error: Sample buffer creation failed (error code: \(err))")
        }
        
        return sampleBuffer
    }
    
    // MARK: - Split Style and Filter
    
    func setSplitStyle(_ style: SplitStyle) {
        currentSplitStyle = style
        videoMixer?.splitStyle = style
    }
    
    func setFilter(_ filter: Filter) {
        currentFilter = filter
    }
    
    // MARK: - System Cost Optimization
    
    private func checkSystemCost(session: AVCaptureMultiCamSession) {
        var exceededSessionCosts: ExceededCaptureSessionCosts = []
        
        if session.systemPressureCost > 1.0 {
            exceededSessionCosts.insert(.systemPressureCost)
        }
        
        if session.hardwareCost > 1.0 {
            exceededSessionCosts.insert(.hardwareCost)
        }
        
        switch exceededSessionCosts {
        case .systemPressureCost:
            if reduceResolutionForCamera(.front, session: session) {
                checkSystemCost(session: session)
            } else if reduceVideoInputPorts(session: session) {
                checkSystemCost(session: session)
            } else if reduceResolutionForCamera(.back, session: session) {
                checkSystemCost(session: session)
            } else if reduceFrameRateForCamera(.front, session: session) {
                checkSystemCost(session: session)
            } else if reduceFrameRateForCamera(.back, session: session) {
                checkSystemCost(session: session)
            } else {
                print("Unable to further reduce session cost.")
            }
            
        case .hardwareCost:
            if reduceResolutionForCamera(.front, session: session) {
                checkSystemCost(session: session)
            } else if reduceResolutionForCamera(.back, session: session) {
                checkSystemCost(session: session)
            } else if reduceFrameRateForCamera(.front, session: session) {
                checkSystemCost(session: session)
            } else if reduceFrameRateForCamera(.back, session: session) {
                checkSystemCost(session: session)
            } else {
                print("Unable to further reduce session cost.")
            }
            
        case [.systemPressureCost, .hardwareCost]:
            if reduceResolutionForCamera(.front, session: session) {
                checkSystemCost(session: session)
            } else if reduceResolutionForCamera(.back, session: session) {
                checkSystemCost(session: session)
            } else if reduceFrameRateForCamera(.front, session: session) {
                checkSystemCost(session: session)
            } else if reduceFrameRateForCamera(.back, session: session) {
                checkSystemCost(session: session)
            } else {
                print("Unable to further reduce session cost.")
            }
            
        default:
            break
        }
    }
    
    struct ExceededCaptureSessionCosts: OptionSet {
        let rawValue: Int
        
        static let systemPressureCost = ExceededCaptureSessionCosts(rawValue: 1 << 0)
        static let hardwareCost = ExceededCaptureSessionCosts(rawValue: 1 << 1)
    }
    
    private func reduceResolutionForCamera(_ position: AVCaptureDevice.Position, session: AVCaptureMultiCamSession) -> Bool {
        for connection in session.connections {
            for inputPort in connection.inputPorts {
                if inputPort.mediaType == .video && inputPort.sourceDevicePosition == position {
                    guard let videoDeviceInput: AVCaptureDeviceInput = inputPort.input as? AVCaptureDeviceInput else {
                        return false
                    }
                    
                    var dims: CMVideoDimensions
                    var width: Int32
                    var height: Int32
                    var activeWidth: Int32
                    var activeHeight: Int32
                    
                    dims = CMVideoFormatDescriptionGetDimensions(videoDeviceInput.device.activeFormat.formatDescription)
                    activeWidth = dims.width
                    activeHeight = dims.height
                    
                    if (activeHeight <= 480) && (activeWidth <= 640) {
                        return false
                    }
                    
                    let formats = videoDeviceInput.device.formats
                    if let formatIndex = formats.firstIndex(of: videoDeviceInput.device.activeFormat) {
                        for index in (0..<formatIndex).reversed() {
                            let format = videoDeviceInput.device.formats[index]
                            if format.isMultiCamSupported {
                                dims = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                                width = dims.width
                                height = dims.height
                                
                                if width < activeWidth || height < activeHeight {
                                    do {
                                        try videoDeviceInput.device.lockForConfiguration()
                                        videoDeviceInput.device.activeFormat = format
                                        videoDeviceInput.device.unlockForConfiguration()
                                        
                                        print("Reduced resolution for \(position == .front ? "front" : "back") camera: width = \(width), height = \(height)")
                                        return true
                                    } catch {
                                        print("Could not lock device for configuration: \(error)")
                                        return false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    private func reduceFrameRateForCamera(_ position: AVCaptureDevice.Position, session: AVCaptureMultiCamSession) -> Bool {
        for connection in session.connections {
            for inputPort in connection.inputPorts {
                if inputPort.mediaType == .video && inputPort.sourceDevicePosition == position {
                    guard let videoDeviceInput: AVCaptureDeviceInput = inputPort.input as? AVCaptureDeviceInput else {
                        return false
                    }
                    
                    let activeMinFrameDuration = videoDeviceInput.device.activeVideoMinFrameDuration
                    var activeMaxFrameRate: Double = Double(activeMinFrameDuration.timescale) / Double(activeMinFrameDuration.value)
                    activeMaxFrameRate -= 10.0
                    
                    if activeMaxFrameRate >= 15.0 {
                        do {
                            try videoDeviceInput.device.lockForConfiguration()
                            videoDeviceInput.videoMinFrameDurationOverride = CMTimeMake(value: 1, timescale: Int32(activeMaxFrameRate))
                            videoDeviceInput.device.unlockForConfiguration()
                            
                            print("Reduced frame rate for \(position == .front ? "front" : "back") camera: \(activeMaxFrameRate) fps")
                            return true
                        } catch {
                            print("Could not lock device for configuration: \(error)")
                            return false
                        }
                    } else {
                        return false
                    }
                }
            }
        }
        
        return false
    }
    
    private func reduceVideoInputPorts(session: AVCaptureMultiCamSession) -> Bool {
        var newConnection: AVCaptureConnection
        var result = false
        
        for connection in session.connections {
            for inputPort in connection.inputPorts where inputPort.sourceDeviceType == .builtInDualCamera {
                print("Changing input from dual to single camera")
                
                guard let videoDeviceInput: AVCaptureDeviceInput = inputPort.input as? AVCaptureDeviceInput,
                    let wideCameraPort: AVCaptureInput.Port = videoDeviceInput.ports(
                        for: .video,
                        sourceDeviceType: .builtInWideAngleCamera,
                        sourceDevicePosition: videoDeviceInput.device.position
                    ).first else {
                        return false
                }
                
                if let previewLayer = connection.videoPreviewLayer {
                    newConnection = AVCaptureConnection(inputPort: wideCameraPort, videoPreviewLayer: previewLayer)
                } else if let savedOutput = connection.output {
                    newConnection = AVCaptureConnection(inputPorts: [wideCameraPort], output: savedOutput)
                } else {
                    continue
                }
                
                session.beginConfiguration()
                session.removeConnection(connection)
                
                if session.canAddConnection(newConnection) {
                    session.addConnection(newConnection)
                    session.commitConfiguration()
                    result = true
                } else {
                    print("Could not add new connection to the session")
                    session.commitConfiguration()
                    return false
                }
            }
        }
        
        return result
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
                    
                    // Apply filter if needed
                    let processedFrontImage: UIImage
                    let processedBackImage: UIImage
                    
                    if self.currentFilter != .none, let filterProcessor = self.filterProcessor {
                        processedFrontImage = filterProcessor.applyFilter(self.currentFilter, to: frontImage) ?? frontImage
                        processedBackImage = filterProcessor.applyFilter(self.currentFilter, to: backImage) ?? backImage
                    } else {
                        processedFrontImage = frontImage
                        processedBackImage = backImage
                    }
                    
                    let combinedImage: UIImage?
                    
                    switch self.currentSplitStyle {
                    case .straight:
                        // Side-by-side split
                        let size = CGSize(
                            width: processedFrontImage.size.width + processedBackImage.size.width,
                            height: max(processedFrontImage.size.height, processedBackImage.size.height)
                        )
                        
                        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                        
                        processedFrontImage.draw(in: CGRect(
                            x: 0,
                            y: 0,
                            width: processedFrontImage.size.width,
                            height: processedFrontImage.size.height
                        ))
                        
                        processedBackImage.draw(in: CGRect(
                            x: processedFrontImage.size.width,
                            y: 0,
                            width: processedBackImage.size.width,
                            height: processedBackImage.size.height
                        ))
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                    case .diagonal:
                        // Diagonal split
                        let size = CGSize(
                            width: max(processedFrontImage.size.width, processedBackImage.size.width),
                            height: max(processedFrontImage.size.height, processedBackImage.size.height)
                        )
                        
                        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                        
                        // Draw back image as base
                        processedBackImage.draw(in: CGRect(origin: .zero, size: size))
                        
                        // Create diagonal mask path
                        let path = UIBezierPath()
                        path.move(to: .zero)
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        path.addLine(to: CGPoint(x: 0, y: size.height))
                        path.close()
                        
                        // Clip to diagonal region and draw front image
                        path.addClip()
                        processedFrontImage.draw(in: CGRect(origin: .zero, size: size))
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                    case .circular:
                        // Circular PiP
                        let size = processedBackImage.size
                        let pipSize = CGSize(width: size.width / 3, height: size.height / 4)
                        let pipOrigin = CGPoint(x: size.width - pipSize.width - 20, y: 20)
                        
                        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                        
                        // Draw back image as base
                        processedBackImage.draw(in: CGRect(origin: .zero, size: size))
                        
                        // Draw front image in circular PiP
                        let pipRect = CGRect(origin: pipOrigin, size: pipSize)
                        let path = UIBezierPath(ovalIn: pipRect)
                        path.addClip()
                        processedFrontImage.draw(in: pipRect)
                        
                        // Draw border
                        UIColor.white.setStroke()
                        path.lineWidth = 2
                        path.stroke()
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                    case .corner:
                        // Corner overlay
                        let size = processedBackImage.size
                        let cornerSize = CGSize(width: size.width / 3, height: size.height / 3)
                        let cornerOrigin = CGPoint(x: size.width - cornerSize.width, y: 0)
                        
                        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                        
                        // Draw back image as base
                        processedBackImage.draw(in: CGRect(origin: .zero, size: size))
                        
                        // Create corner mask path
                        let path = UIBezierPath()
                        path.move(to: cornerOrigin)
                        path.addLine(to: CGPoint(x: size.width, y: 0))
                        path.addLine(to: CGPoint(x: size.width, y: cornerSize.height))
                        path.addLine(to: CGPoint(x: size.width - cornerSize.width, y: cornerSize.height))
                        path.close()
                        
                        // Clip to corner region and draw front image
                        path.addClip()
                        processedFrontImage.draw(in: CGRect(origin: .zero, size: size))
                        
                        combinedImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    }
                    
                    guard let finalImage = combinedImage else {
                        continuation.resume(throwing: CameraError.processingError)
                        return
                    }
                    
                    // Save the combined image
                    let combinedFileName = "combined_photo_\(UUID().uuidString).jpg"
                    let combinedURL = self.getDocumentsDirectory().appendingPathComponent(combinedFileName)
                    
                    if let combinedData = finalImage.jpegData(compressionQuality: 0.8) {
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
