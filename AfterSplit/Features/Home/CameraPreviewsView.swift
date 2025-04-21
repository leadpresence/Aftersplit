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
    
    var body: some View {
        // This is a placeholder for the actual camera previews
        // In a real implementation, you would use CameraPreview to show the camera feeds
        GeometryReader { geometry in
            ZStack {
                // Back camera preview (full screen)
                Color.black
                    .overlay(
                        Text("Back Camera")
                            .foregroundColor(.white)
                    )
                
                // Front camera preview (picture-in-picture)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.8))
                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 4)
                            .overlay(
                                Text("Front Camera")
                                    .foregroundColor(.white)
                            )
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
        }
    }
}
