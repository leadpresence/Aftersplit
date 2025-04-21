//
//  CameraUsecaseSec.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI
protocol CameraUsecaseSec {
    func checkCameraPermissions() async -> Bool
    func startSession()
    func stopSession()
    func capturePhoto() async throws -> [URL]
    func startRecording() async throws
    func stopRecording() async throws -> [URL]
    func getSavedMedia() -> [MediaItem]
}
