//
//  CameraRepositorySec.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI

protocol CameraRepositorySec {
    func setupCaptureSession() throws
    func startSession()
    func stopSession()
    func capturePhoto() async throws -> [URL]
    func startRecording() async throws
    func stopRecording() async throws -> [URL]
    func getAllSavedMedia() -> [MediaItem]
    func saveImage(_ image: UIImage, withName name: String) throws -> URL
    func getDocumentsDirectory() -> URL
}
