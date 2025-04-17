import SwiftUI
protocol CameraRepositoryProtocol {
    func savePhoto(_ photo: Photo) async throws
    func saveVideo(_ video: Video) async throws
    func fetchPhotos() async throws -> [Photo]
    func fetchVideos() async throws -> [Video]
    func deletePhoto(id: UUID) async throws
    func deleteVideo(id: UUID) async throws
}
