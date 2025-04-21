//
//  CameraView.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import AVFoundation
import UIKit
import SwiftUI

// Camera View
struct CameraView: View {
    @EnvironmentObject var viewModel: CameraViewModelSec
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if viewModel.isSessionSetup {
                VStack(spacing: 0) {
                    // Camera previews
                    CameraPreviewsView()
                    
                    // Controls
                    CameraControlsView()
                        .padding()
                }
            } else if !viewModel.isCameraAuthorized {
                VStack {
                    Text("Camera access required")
                        .font(.headline)
                        .padding()
                    
                    Text("Please grant camera access in Settings to use this app.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView("Setting up cameras...")
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.startSession()
            } else if newPhase == .inactive {
                viewModel.stopSession()
            }
        }
        .onAppear {
            // Start the camera session when the view appears
            viewModel.startSession()
        }
        .onDisappear {
            // Stop the camera session when the view disappears
            viewModel.stopSession()
        }
    }
}
