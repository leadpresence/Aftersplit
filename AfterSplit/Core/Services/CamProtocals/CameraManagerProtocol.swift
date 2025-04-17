
import Foundation
import SwiftUI

protocol CameraManagerProtocol {
    var currentFilter: Filter { get }
    var currentSplitStyle: SplitStyle { get }
    
    func setupDualCamera() async throws
    func captureStillImage() async throws -> (front: Data, back: Data)
    func startRecording() async throws
    func stopRecording() async throws -> (url: URL, duration: TimeInterval)
    func toggleCamera() async
    func applyFilter(_ filter: Filter)
    func setSplitStyle(_ style: SplitStyle)
    func getCurrentPreviewFrames() -> (front: UIImage?, back: UIImage?)
}

