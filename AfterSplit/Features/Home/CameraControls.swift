//
//  CameraControls.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
 
import SwiftUI

struct CameraControlsView: View {
    @EnvironmentObject var viewModel: CameraViewModelSec
    
    var body: some View {
        HStack(spacing: 60) {
            // Photo capture button
            Button(action: {
                viewModel.capturePhoto()
            }) {
                Image(systemName: "camera")
                    .font(.system(size: 24))
            }}}}
