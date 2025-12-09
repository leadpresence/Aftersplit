//
//  CameraPreviewsView.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import AVFoundation
import UIKit
import SwiftUI

struct CameraPreviewsView: View {
    @EnvironmentObject var viewModel: CameraViewModelSec
    @State private var currentSplitStyle: SplitStyle = .straight
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Back camera preview (full screen)
                if let backPreviewLayer = viewModel.backPreviewLayer {
                    PreviewLayerView(previewLayer: backPreviewLayer)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.black
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
                
                // Front camera preview overlay based on split style
                if let frontPreviewLayer = viewModel.frontPreviewLayer {
                    frontCameraOverlay(
                        previewLayer: frontPreviewLayer,
                        geometry: geometry,
                        splitStyle: currentSplitStyle
                    )
                }
            }
        }
        .onAppear {
            // Get current split style from view model if available
            // This will be updated when we add state management
        }
    }
    
    @ViewBuilder
    private func frontCameraOverlay(
        previewLayer: AVCaptureVideoPreviewLayer,
        geometry: GeometryProxy,
        splitStyle: SplitStyle
    ) -> some View {
        switch splitStyle {
        case .straight:
            // Side-by-side split
            HStack(spacing: 0) {
                PreviewLayerView(previewLayer: previewLayer)
                    .frame(width: geometry.size.width / 2)
                Spacer()
            }
            
        case .diagonal:
            // Diagonal split - overlay with diagonal mask
            PreviewLayerView(previewLayer: previewLayer)
                .mask(DiagonalMask())
            
        case .circular:
            // Picture-in-picture with circular mask
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PreviewLayerView(previewLayer: previewLayer)
                        .frame(width: geometry.size.width / 3, height: geometry.size.height / 4)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .padding()
                }
            }
            
        case .corner:
            // Corner overlay
            PreviewLayerView(previewLayer: previewLayer)
                .mask(CornerMask())
        }
    }
}
