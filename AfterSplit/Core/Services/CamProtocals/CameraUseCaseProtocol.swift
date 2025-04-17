import Foundation
import SwiftUI

protocol CameraUseCaseProtocol {
    func capturePhoto() async throws -> Photo
    func startRecording() async throws
    func stopRecording() async throws -> Video
    func toggleCamera() async
    func applyFilter(_ filter: Filter)
    func setSplitStyle(_ style: SplitStyle)
    func setupCamera() async throws
    func getCurrentPreviewFrames() -> (front: UIImage?, back: UIImage?)
}
