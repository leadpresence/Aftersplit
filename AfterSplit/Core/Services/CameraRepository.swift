import SwiftUI

class CameraRepository: CameraRepositoryProtocol {
    private let storageService: StorageServiceProtocol
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
    }
    
    func savePhoto(_ photo: Photo) async throws {
        try await storageService.savePhoto(photo)
    }
    
    func saveVideo(_ video: Video) async throws {
        try await storageService.saveVideo(video)
    }
    
    func fetchPhotos() async throws -> [Photo] {
        return try await storageService.fetchPhotos()
    }
    
    func fetchVideos() async throws -> [Video] {
        return try await storageService.fetchVideos()
    }
    
    func deletePhoto(id: UUID) async throws {
        try await storageService.deletePhoto(id: id)
    }
    
    func deleteVideo(id: UUID) async throws {
        try await storageService.deleteVideo(id: id)
    }
}
