/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Records movies using AVAssetWriter.
*/

import Foundation
import AVFoundation

class MovieRecorder {
    
    private var assetWriter: AVAssetWriter?
    
    private var assetWriterVideoInput: AVAssetWriterInput?
    
    private var assetWriterAudioInput: AVAssetWriterInput?
    
    private var videoTransform: CGAffineTransform
    
    private var videoSettings: [String: Any]
    
    private var audioSettings: [String: Any]
    
    private(set) var isRecording = false
    
    private var outputURL: URL?
    
    init(audioSettings: [String: Any], videoSettings: [String: Any], videoTransform: CGAffineTransform) {
        self.audioSettings = audioSettings
        self.videoSettings = videoSettings
        self.videoTransform = videoTransform
    }
    
    func startRecording(to outputURL: URL) {
        self.outputURL = outputURL
        
        // Create an asset writer that records to the specified file
        guard let assetWriter = try? AVAssetWriter(url: outputURL, fileType: .mov) else {
            print("Failed to create AVAssetWriter")
            return
        }
        
        // Add an audio input if audio settings are provided
        if !audioSettings.isEmpty {
            let assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            assetWriterAudioInput.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(assetWriterAudioInput) {
                assetWriter.add(assetWriterAudioInput)
                self.assetWriterAudioInput = assetWriterAudioInput
            }
        }
        
        // Add a video input
        let assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = videoTransform
        if assetWriter.canAdd(assetWriterVideoInput) {
            assetWriter.add(assetWriterVideoInput)
            self.assetWriterVideoInput = assetWriterVideoInput
        }
        
        self.assetWriter = assetWriter
        
        isRecording = true
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard let assetWriter = assetWriter else {
            completion(nil)
            return
        }
        
        self.isRecording = false
        
        assetWriter.finishWriting { [weak self] in
            let url = assetWriter.outputURL
            self?.assetWriter = nil
            self?.assetWriterVideoInput = nil
            self?.assetWriterAudioInput = nil
            completion(url)
        }
    }
    
    func recordVideo(sampleBuffer: CMSampleBuffer) {
        guard isRecording,
            let assetWriter = assetWriter else {
                return
        }
        
        if assetWriter.status == .unknown {
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        } else if assetWriter.status == .writing {
            if let input = assetWriterVideoInput,
                input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        }
    }
    
    func recordAudio(sampleBuffer: CMSampleBuffer) {
        guard isRecording,
            let assetWriter = assetWriter,
            assetWriter.status == .writing,
            let input = assetWriterAudioInput,
            input.isReadyForMoreMediaData else {
                return
        }
        
        input.append(sampleBuffer)
    }
}

