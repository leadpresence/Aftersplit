//
//  PhotoCaptureDelegate.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI
import AVFoundation

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let willCapturePhotoAnimation: () -> Void
    private let didFinishProcessingPhoto: (Data?) -> Void
    
    init(willCapturePhotoAnimation: @escaping () -> Void,
         didFinishProcessingPhoto: @escaping (Data?) -> Void) {
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.didFinishProcessingPhoto = didFinishProcessingPhoto
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            didFinishProcessingPhoto(nil)
            return
        }
        
        didFinishProcessingPhoto(photo.fileDataRepresentation())
    }
}
