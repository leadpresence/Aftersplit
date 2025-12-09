//
//  CameraControls.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
 
import SwiftUI

struct CameraControlsView: View {
    @EnvironmentObject var viewModel: CameraViewModelSec
    @State private var showGallery = false
    
    var body: some View {
        VStack {
            // Top controls
            HStack {
                // Split style selector
                SplitStyleSelector(
                    currentStyle: viewModel.currentSplitStyle,
                    onStyleSelected: { style in
                        viewModel.updateSplitStyle(style)
                    }
                )
                
                Spacer()
                
                // Filter selector
                FilterSelector(
                    currentFilter: viewModel.currentFilter,
                    onFilterSelected: { filter in
                        viewModel.updateFilter(filter)
                    }
                )
            }
            .padding()
            
            Spacer()
            
            // Recording time indicator
            if viewModel.isRecording {
                Text("Recording...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.red.opacity(0.8))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            // Bottom controls
            HStack {
                // Gallery button
                Button(action: {
                    showGallery = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Capture photo button
                Button(action: {
                    viewModel.capturePhoto()
                }) {
                    Image(systemName: "camera")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .buttonStyle(CameraButtonStyle())
                
                Spacer()
                
                // Toggle recording button
                Button(action: {
                    viewModel.toggleRecording()
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "video")
                        .font(.system(size: 24))
                        .foregroundColor(viewModel.isRecording ? .red : .white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .sheet(isPresented: $showGallery) {
            GalleryView()
        }
    }
}
