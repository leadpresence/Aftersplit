//
//  CameraError.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

enum CameraError: Error {
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
}
