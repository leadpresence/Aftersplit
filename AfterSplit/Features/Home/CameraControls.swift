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
    @State private var photoCaptureAnimation = false
    
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
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .opacity(viewModel.isRecording ? 1.0 : 0.0)
                        .animation(
                            Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: viewModel.isRecording
                        )
                    
                    Text(viewModel.formattedRecordingTime())
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
            
            // Bottom controls
            HStack {
                // Gallery button
                Button(action: {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    showGallery = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Capture photo button
                Button(action: {
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    // Visual feedback
                    withAnimation(.easeInOut(duration: 0.1)) {
                        photoCaptureAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            photoCaptureAnimation = false
                        }
                    }
                    
                    viewModel.capturePhoto()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(photoCaptureAnimation ? 0.9 : 1.0)
                }
                .buttonStyle(CameraButtonStyle())
                
                Spacer()
                
                // Toggle recording button
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                    viewModel.toggleRecording()
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? Color.red.opacity(0.3) : Color.black.opacity(0.6))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "video")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.isRecording ? .red : .white)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showGallery) {
            GalleryView()
        }
    }
}
