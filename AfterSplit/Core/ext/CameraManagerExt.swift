//
//  CameraManager.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//


import AVFoundation

extension CameraManager {
    func checkCameraPermissions() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
}
