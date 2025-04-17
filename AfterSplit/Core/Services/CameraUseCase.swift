import Foundation
import SwiftUI

class CameraUseCase: CameraUseCaseProtocol {
    private let cameraRepository: CameraRepositoryProtocol
    private let cameraManager: CameraManagerProtocol
    
    init(cameraRepository: CameraRepositoryProtocol, cameraManager: CameraManagerProtocol) {
        self.cameraRepository = cameraRepository
        self.cameraManager = cameraManager
    }
    
    func setupCamera() async throws {
        try await cameraManager.setupDualCamera()
    }
    
    func capturePhoto() async throws -> Photo {
        let capturedImages = try await cameraManager.captureStillImage()
        let photo = Photo(
            id: UUID(),
            frontImage: capturedImages.front,
            backImage: capturedImages.back,
            timestamp: Date(),
            appliedFilter: cameraManager.currentFilter
        )
        try await cameraRepository.savePhoto(photo)
        return photo
    }
    
    func startRecording() async throws {
        try await cameraManager.startRecording()
    }
    
    func stopRecording() async throws -> Video {
        let recordedVideo = try await cameraManager.stopRecording()
        let video = Video(
            id: UUID(),
            url: recordedVideo.url,
            duration: recordedVideo.duration,
            timestamp: Date(),
            appliedFilter: cameraManager.currentFilter
        )
        try await cameraRepository.saveVideo(video)
        return video
    }
    
    func toggleCamera() async {
        await cameraManager.toggleCamera()
    }
    
    func applyFilter(_ filter: Filter) {
        cameraManager.applyFilter(filter)
    }
    
    func setSplitStyle(_ style: SplitStyle) {
        cameraManager.setSplitStyle(style)
    }
    
    func getCurrentPreviewFrames() -> (front: UIImage?, back: UIImage?) {
        return cameraManager.getCurrentPreviewFrames()
    }
}
