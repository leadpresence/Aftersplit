//
//  GalleryView.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//

import SwiftUI
struct GalleryView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var galleryViewModel = GalleryViewModel(
        cameraRepository: DefaultCameraRepository()
    )
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("Media Type", selection: $selectedTab) {
                    Text("Photos").tag(0)
                    Text("Videos").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                if selectedTab == 0 {
                    // Photos grid
                    if galleryViewModel.photos.isEmpty {
                        EmptyStateView(mediaType: "photos")
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(galleryViewModel.photos, id: \.id) { photo in
                                    PhotoThumbnailView(photo: photo)
                                        .onTapGesture {
                                            galleryViewModel.selectPhoto(photo)
                                        }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                } else {
                    // Videos grid
                    if galleryViewModel.videos.isEmpty {
                        EmptyStateView(mediaType: "videos")
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(galleryViewModel.videos, id: \.id) { video in
                                    VideoThumbnailView(video: video)
                                        .onTapGesture {
                                            galleryViewModel.selectVideo(video)
                                        }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
            .onAppear {
                galleryViewModel.loadMedia()
            }
            .sheet(item: $galleryViewModel.selectedPhoto) { photo in
                PhotoDetailView(photo: photo)
            }
            .sheet(item: $galleryViewModel.selectedVideo) { video in
                VideoPlayerView(video: video)
            }
        }
    }
}
