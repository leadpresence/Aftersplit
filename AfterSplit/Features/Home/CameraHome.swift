import SwiftUI

struct ASContentView: View {
    
    @StateObject private var viewModel: CameraViewModel
        @State private var showGallery = false
        
        init(viewModel: CameraViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }
        
        var body: some View {
            ZStack {
                // Camera preview
                CameraPreviewView(
                    frontPreview: viewModel.frontPreview,
                    backPreview: viewModel.backPreview,
                    splitStyle: viewModel.splitStyle
                )
                
                // Camera controls overlay
                VStack {
                    // Top controls
                    HStack {
                        // Split style selector
                        SplitStyleSelector(
                            currentStyle: viewModel.splitStyle,
                            onStyleSelected: viewModel.updateSplitStyle
                        )
                        
                        Spacer()
                        
                        // Filter selector
                        FilterSelector(
                            currentFilter: viewModel.currentFilter,
                            onFilterSelected: viewModel.updateFilter
                        )
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Recording time indicator
                    if viewModel.isRecording {
                        Text(viewModel.formattedRecordingTime())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.black.opacity(0.6))
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
                        Button(action: viewModel.capturePhoto) {
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
                        Button(action: viewModel.toggleRecording) {
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
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                viewModel.setupCamera()
            }
            .sheet(isPresented: $showGallery) {
                GalleryView()
            }
            .alert(isPresented: .constant(viewModel.error != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.error?.localizedDescription ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"), action: {
                        viewModel.error = nil
                    })
                )
            }
        }
    
//    @StateObject private var viewModel: CameraViewModel
//    @State private var showGallery = false
//    @State private var showHelp = false
//    @State private var showPermissionAlert = false
//    
//    init(viewModel: CameraViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    var body: some View {
//        ZStack {
//            // Camera preview
//            CameraPreviewView(
//                frontPreview: viewModel.frontPreview,
//                backPreview: viewModel.backPreview,
//                splitStyle: viewModel.splitStyle
//            )
//            
//            // Camera controls overlay
//            VStack {
//                // Top controls
//                HStack {
//                    // Split style selector
//                    SplitStyleSelector(
//                        currentStyle: viewModel.splitStyle,
//                        onStyleSelected: viewModel.updateSplitStyle
//                    )
//                    
//                    Spacer()
//                    
//                    // Help button
//                    Button(action: {
//                        showHelp = true
//                    }) {
//                        Image(systemName: "questionmark.circle")
//                            .font(.system(size: 20))
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.6))
//                            .clipShape(Circle())
//                    }
//                    
//                    // Filter selector
//                    FilterSelector(
//                        currentFilter: viewModel.currentFilter,
//                        onFilterSelected: viewModel.updateFilter
//                    )
//                }
//                .padding()
//                
//                Spacer()
//                
//                // Recording time indicator
//                if viewModel.isRecording {
//                    Text(viewModel.formattedRecordingTime())
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 16)
//                        .background(Color.black.opacity(0.6))
//                        .clipShape(Capsule())
//                }
//                
//                Spacer()
//                
//                // Bottom controls
//                HStack {
//                    // Gallery button
//                    Button(action: {
//                        showGallery = true
//                    }) {
//                        Image(systemName: "photo.on.rectangle")
//                            .font(.system(size: 24))
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.black.opacity(0.6))
//                            .clipShape(Circle())
//                    }
//                    
//                    Spacer()
//                    
//                    // Capture photo button
//                    Button(action: {
//                        Task {
//                            let hasPermission = await viewModel.checkCameraPermissions()
//                            if hasPermission {
//                                viewModel.capturePhoto()
//                            } else {
//                                showPermissionAlert = true
//                            }
//                        }
//                    }) {
//                        Image(systemName: "camera")
//                            .font(.system(size: 30))
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.white.opacity(0.2))
//                            .clipShape(Circle())
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.white, lineWidth: 2)
//                            )
//                    }
//                    .buttonStyle(CameraButtonStyle())
//                    
//                    Spacer()
//                    
//                    // Toggle recording button
//                    Button(action: {
//                        Task {
//                            let hasPermission = await viewModel.checkCameraPermissions()
//                            if hasPermission {
//                                viewModel.toggleRecording()
//                            } else {
//                                showPermissionAlert = true
//                            }
//                        }
//                    }) {
//                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "video")
//                            .font(.system(size: 24))
//                            .foregroundColor(viewModel.isRecording ? .red : .white)
//                            .padding()
//                            .background(Color.black.opacity(0.6))
//                            .clipShape(Circle())
//                    }
//                }
//                .padding()
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//        .onAppear {
//            viewModel.setupCamera()
//        }
//        .sheet(isPresented: $showGallery) {
//            GalleryView()
//        }
//        .sheet(isPresented: $showHelp) {
//            HelpView()
//        }
//        .alert(isPresented: $showPermissionAlert) {
//            Alert(
//                title: Text("Camera Access Required"),
//                message: Text("Please enable camera access in Settings to use this feature."),
//                primaryButton: .default(Text("Open Settings"), action: {
//                    if let url = URL(string: UIApplication.openSettingsURLString) {
//                        UIApplication.shared.open(url)
//                    }
//                }),
//                secondaryButton: .cancel()
//            )
//        }
//        .alert(isPresented: .constant(viewModel.error != nil)) {
//            Alert(
//                title: Text("Error"),
//                message: Text(viewModel.error?.localizedDescription ?? "An unknown error occurred"),
//                dismissButton: .default(Text("OK"), action: {
//                    viewModel.error = nil
//                })
//            )
//        }
//    }
}
