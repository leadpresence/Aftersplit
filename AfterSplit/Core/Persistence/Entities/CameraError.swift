//
//  CameraError.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

enum CameraError: Error, LocalizedError {
    case multiCamNotSupported
    case cameraUnavailable
    case permissionDenied
    case inputError
    case outputError
    case connectionError
    case portError
    case hardwareCostTooHigh
    case processingError
    case fileError
    case alreadyRecording
    case notRecording
    
    var errorDescription: String? {
        switch self {
        case .multiCamNotSupported:
            return "Multi-camera is not supported on this device"
        case .cameraUnavailable:
            return "Camera is currently unavailable"
        case .permissionDenied:
            return "Camera permission was denied. Please enable it in Settings."
        case .inputError:
            return "Failed to configure camera input"
        case .outputError:
            return "Failed to configure camera output"
        case .connectionError:
            return "Failed to establish camera connection"
        case .portError:
            return "Failed to access camera port"
        case .hardwareCostTooHigh:
            return "Camera configuration exceeds device capabilities"
        case .processingError:
            return "Failed to process media"
        case .fileError:
            return "Failed to access file system"
        case .alreadyRecording:
            return "Recording is already in progress"
        case .notRecording:
            return "No active recording to stop"
        }
    }
}
