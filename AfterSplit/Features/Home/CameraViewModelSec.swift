//
//  CameraViewModelSec.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import Combine
import AVFoundation

class CameraViewModelSec: ObservableObject {
    private let useCase: CameraUsecaseSec
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties
    @Published var isSessionSetup = false
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var errorMessage: String?
    @Published var savedMedia: [MediaItem] = []
    @Published var isCameraAuthorized = false
    @Published var currentSplitStyle: SplitStyle = .straight
    @Published var currentFilter: Filter = .none
    
    // References for previews
    var frontPreviewLayer: AVCaptureVideoPreviewLayer?
    var backPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Timer for recording duration
    private var recordingTimer: Timer?
    
    init() {
        let repository = DefaultCameraRepository()
        self.useCase = DefaultCameraUseCase(repository: repository)
        
        Task {
            await setupSession()
        }
    }
    
    func setupSession() async {
        // Check permissions first
        let isAuthorized = await useCase.checkCameraPermissions()
        
        await MainActor.run {
            self.isCameraAuthorized = isAuthorized
        }
        
        if isAuthorized {
            do {
                if let repository = (useCase as? DefaultCameraUseCase)?.repository as? DefaultCameraRepository {
                    try repository.setupCaptureSession()
                    
                    await MainActor.run {
                        // Get preview layers from repository
                        self.frontPreviewLayer = repository.getFrontPreviewLayer()
                        self.backPreviewLayer = repository.getBackPreviewLayer()
                        self.isSessionSetup = true
                    }
                    
                    loadSavedMedia()
                }
            } catch {
                await MainActor.run {
                    if let cameraError = error as? CameraError {
                        self.errorMessage = cameraError.localizedDescription
                    } else {
                        self.errorMessage = "Failed to setup camera: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            await MainActor.run {
                self.errorMessage = "Camera access denied"
            }
        }
    }
    
    func startSession() {
        useCase.startSession()
    }
    
    func stopSession() {
        useCase.stopSession()
    }
    
    func capturePhoto() {
        Task {
            do {
                _ = try await useCase.capturePhoto()
                await MainActor.run {
                    loadSavedMedia()
                }
            } catch {
                await MainActor.run {
                    if let cameraError = error as? CameraError {
                        self.errorMessage = cameraError.localizedDescription
                    } else {
                        self.errorMessage = "Failed to capture photo: \(error.localizedDescription)"
                    }
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
    
    func toggleRecording() {
        Task {
            do {
                if isRecording {
                    _ = try await useCase.stopRecording()
                    await MainActor.run {
                        self.isRecording = false
                        self.recordingTime = 0
                        stopRecordingTimer()
                        loadSavedMedia()
                    }
                } else {
                    try await useCase.startRecording()
                    await MainActor.run {
                        self.isRecording = true
                        self.recordingTime = 0
                        startRecordingTimer()
                        // Haptic feedback
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }
            } catch {
                await MainActor.run {
                    if let cameraError = error as? CameraError {
                        self.errorMessage = cameraError.localizedDescription
                    } else {
                        self.errorMessage = "Recording error: \(error.localizedDescription)"
                    }
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isRecording else { return }
            DispatchQueue.main.async {
                self.recordingTime += 0.1
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func formattedRecordingTime() -> String {
        let totalSeconds = Int(recordingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func loadSavedMedia() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let media = self?.useCase.getSavedMedia() ?? []
            
            DispatchQueue.main.async {
                self?.savedMedia = media
            }
        }
    }
    
    func updateSplitStyle(_ style: SplitStyle) {
        guard currentSplitStyle != style else { return }
        currentSplitStyle = style
        if let repository = (useCase as? DefaultCameraUseCase)?.repository as? DefaultCameraRepository {
            repository.setSplitStyle(style)
        }
        // Haptic feedback for style change
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func updateFilter(_ filter: Filter) {
        guard currentFilter != filter else { return }
        currentFilter = filter
        if let repository = (useCase as? DefaultCameraUseCase)?.repository as? DefaultCameraRepository {
            repository.setFilter(filter)
        }
        // Haptic feedback for filter change
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    deinit {
        stopRecordingTimer()
    }
}
