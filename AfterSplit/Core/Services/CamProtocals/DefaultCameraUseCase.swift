//
//  DefaultCameraUseCase.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI
import AVFoundation

class DefaultCameraUseCase: CameraUsecaseSec {
      let repository: CameraRepositorySec
    
    init(repository: CameraRepositorySec) {
        self.repository = repository
    }
    
    func checkCameraPermissions() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .authorized {
            return true
        } else if status == .notDetermined {
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        
        return false
    }
    
    func startSession() {
        repository.startSession()
    }
    
    func stopSession() {
        repository.stopSession()
    }
    
    func capturePhoto() async throws -> [URL] {
        return try await repository.capturePhoto()
    }
    
    func startRecording() async throws {
        try await repository.startRecording()
    }
    
    func stopRecording() async throws -> [URL] {
        return try await repository.stopRecording()
    }
    
    func getSavedMedia() -> [MediaItem] {
        return repository.getAllSavedMedia()
    }
}
