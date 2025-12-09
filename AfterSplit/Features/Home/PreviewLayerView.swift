//
//  PreviewLayerView.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import AVFoundation
import UIKit
import SwiftUI

struct PreviewLayerView: UIViewRepresentable {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        if let previewLayer = previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = previewLayer {
            // Update frame if needed
            if previewLayer.superlayer != uiView.layer {
                previewLayer.removeFromSuperlayer()
                previewLayer.frame = uiView.bounds
                uiView.layer.addSublayer(previewLayer)
            } else {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

