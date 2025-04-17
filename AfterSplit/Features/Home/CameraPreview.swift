// Camera preview view

import SwiftUI
struct CameraPreviewView: View {
    let frontPreview: UIImage?
    let backPreview: UIImage?
    let splitStyle: SplitStyle
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let front = frontPreview, let back = backPreview {
                    switch splitStyle {
                    case .straight:
                        // Straight split (side by side)
                        HStack(spacing: 0) {
                            Image(uiImage: back)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width/2, height: geometry.size.height)
                                .clipped()
                            
                            Image(uiImage: front)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width/2, height: geometry.size.height)
                                .clipped()
                        }
                        
                    case .diagonal:
                        // Diagonal split
                        ZStack {
                            Image(uiImage: back)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                            
                            Image(uiImage: front)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipShape(DiagonalMask())
                                .clipped()
                        }
                        
                    case .circular:
                        // Circular split (picture in picture)
                        ZStack {
                            Image(uiImage: back)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                            
                            Image(uiImage: front)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                        }
                        
                    case .corner:
                        // Corner split
                        ZStack {
                            Image(uiImage: back)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                            
                            Image(uiImage: front)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipShape(CornerMask())
                                .clipped()
                        }
                    }
                } else {
                    // Show loading or placeholder if no previews available
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                        
                        Text("Initializing camera...")
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                }
            }
        }
    }
}
