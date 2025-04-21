//
//  VideoRecordingDelegate.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import SwiftUI
import AVFoundation

class VideoRecordingDelegate: NSObject, AVCaptureFileOutputRecordingDelegate {
    private let finishedRecording: (Bool, Error?) -> Void
    
    init(finishedRecording: @escaping (Bool, Error?) -> Void) {
        self.finishedRecording = finishedRecording
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Recording started
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        finishedRecording(error == nil, error)
    }
}
