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
    @Published var errorMessage: String?
    @Published var savedMedia: [MediaItem] = []
    @Published var isCameraAuthorized = false
    
    // References for previews
    var frontPreviewLayer: AVCaptureVideoPreviewLayer?
    var backPreviewLayer: AVCaptureVideoPreviewLayer?
    
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
                        self.isSessionSetup = true
                    }
                    
                    loadSavedMedia()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to setup camera: \(error.localizedDescription)"
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
                    self.errorMessage = "Failed to capture photo: \(error.localizedDescription)"
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
                        loadSavedMedia()
                    }
                } else {
                    try await useCase.startRecording()
                    await MainActor.run {
                        self.isRecording = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Recording error: \(error.localizedDescription)"
                }
            }
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
}
