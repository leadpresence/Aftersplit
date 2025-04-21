import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var videos: [Video] = []
    @Published var selectedPhoto: Photo?
    @Published var selectedVideo: Video?
    @Published var error: Error?
    
    private let cameraRepository: CameraRepositorySec
    
    init(cameraRepository: CameraRepositorySec) {
        self.cameraRepository = cameraRepository
    }
    
    func loadMedia() {
        Task {
            do {
                let fetchedPhotos = try await cameraRepository.getAllSavedMedia()
                let fetchedVideos = try await cameraRepository.getAllSavedMedia()
                
//                await MainActor.run {
//                    self.photos = fetchedPhotos
//                    self.videos = fetchedVideos
//                }
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
