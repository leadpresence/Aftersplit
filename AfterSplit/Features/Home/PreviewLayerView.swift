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
        guard let previewLayer = previewLayer else { return }
        
        // Update frame if needed
        if previewLayer.superlayer != uiView.layer {
            previewLayer.removeFromSuperlayer()
            previewLayer.frame = uiView.bounds
            uiView.layer.addSublayer(previewLayer)
        } else {
            // Animate frame changes smoothly
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            previewLayer.frame = uiView.bounds
            CATransaction.commit()
        }
    }
}

