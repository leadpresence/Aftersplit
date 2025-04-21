//
//  ContentView.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//

import AVFoundation
import UIKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CameraViewModelSec
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
                .tag(0)
            
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }
                .tag(1)
        }
        .onAppear {
            // Load saved media when the app appears
            viewModel.loadSavedMedia()
        }
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage != nil ? AlertItem(message: viewModel.errorMessage!) : nil },
            set: { _ in viewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}
