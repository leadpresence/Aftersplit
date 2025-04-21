//
//  CameraPreviewSec.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import AVFoundation
import UIKit
import SwiftUI

struct CameraPreviewSec: UIViewRepresentable {
    var session: AVCaptureSession
    var videoGravity: AVLayerVideoGravity = .resizeAspectFill
    var onChange: (AVCaptureVideoPreviewLayer) -> Void = { _ in }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = videoGravity
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        onChange(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

