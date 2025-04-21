
import Foundation
import SwiftUI

class CameraViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var currentFilter: Filter = .none
    @Published var splitStyle: SplitStyle = .straight
    @Published var frontPreview: UIImage?
    @Published var backPreview: UIImage?
    @Published var error: Error?
    
    // Camera use case
    private let cameraUseCase: CameraUseCaseProtocol
    
    // Timer for recording duration
    private var recordingTimer: Timer?
    
    // Timer for updating preview
    private var previewUpdateTimer: Timer?
    
    init(cameraUseCase: CameraUseCaseProtocol) {
        self.cameraUseCase = cameraUseCase
        
        // Start a timer to update the preview frames
        setupCamera()
    }
    
    
    // Setup camera session
    func setupCamera() {
        Task {
            do {
                try await cameraUseCase.setupCamera()
                startPreviewUpdates()
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    // Update preview frames
    private func startPreviewUpdates() {
        previewUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let frames = self.cameraUseCase.getCurrentPreviewFrames()
            
            DispatchQueue.main.async {
                self.frontPreview = frames.front
                self.backPreview = frames.back
            }
        }
    }
    
    // Capture photo
    func capturePhoto() {
        Task {
            do {
                let _ = try await cameraUseCase.capturePhoto()
                // Photo saved, could notify user or show preview
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    // Toggle recording
    func toggleRecording() {
        Task {
            if isRecording {
                do {
                    let _ = try await cameraUseCase.stopRecording()
                    stopRecordingTimer()
                    
                    await MainActor.run {
                        isRecording = false
                        recordingTime = 0
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                    }
                }
            } else {
                do {
                    try await cameraUseCase.startRecording()
                    startRecordingTimer()
                    
                    await MainActor.run {
                        isRecording = true
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                    }
                }
            }
        }
    }
    
    // Start recording timer
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.recordingTime += 1
                
                // Stop recording after 20 minutes (1200 seconds)
                if self.recordingTime >= 1200 {
                    self.toggleRecording()
                }
            }
        }
    }
    
    // Stop recording timer
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // Update filter
    func updateFilter(_ filter: Filter) {
        currentFilter = filter
        cameraUseCase.applyFilter(filter)
    }
    
    // Update split style
    func updateSplitStyle(_ style: SplitStyle) {
        splitStyle = style
        cameraUseCase.setSplitStyle(style)
    }
    
    // Toggle camera
    func toggleCamera() {
        Task {
            await cameraUseCase.toggleCamera()
        }
    }
    
    // Format time for display
    func formattedRecordingTime() -> String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Clean up
    func cleanup() {
        previewUpdateTimer?.invalidate()
        recordingTimer?.invalidate()
    }
}
