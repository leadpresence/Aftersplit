import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var videos: [Video] = []
    @Published var selectedPhoto: Photo?
    @Published var selectedVideo: Video?
    @Published var error: Error?
    
    private let cameraRepository: CameraRepositoryProtocol
    
    init(cameraRepository: CameraRepositoryProtocol) {
        self.cameraRepository = cameraRepository
    }
    
    func loadMedia() {
        Task {
            do {
                let fetchedPhotos = try await cameraRepository.fetchPhotos()
                let fetchedVideos = try await cameraRepository.fetchVideos()
                
                await MainActor.run {
                    self.photos = fetchedPhotos
                    self.videos = fetchedVideos
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    func selectPhoto(_ photo: Photo) {
        selectedPhoto = photo
    }
    
    func selectVideo(_ video: Video) {
        selectedVideo = video
    }
}
