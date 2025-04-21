//// Camera preview view
//
//import SwiftUI
//import AVFoundation
//
//struct CameraPreviewView: View {
//    let frontPreview: UIImage?
//    let backPreview: UIImage?
//    let splitStyle: SplitStyle
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Background
//                Color.black.edgesIgnoringSafeArea(.all)
//                
//                if let front = frontPreview, let back = backPreview {
//                    switch splitStyle {
//                    case .straight:
//                        // Straight split (side by side)
//                        HStack(spacing: 0) {
//                            Image(uiImage: back)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width/2, height: geometry.size.height)
//                                .clipped()
//                            
//                            Image(uiImage: front)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width/2, height: geometry.size.height)
//                                .clipped()
//                        }
//                        
//                    case .diagonal:
//                        // Diagonal split
//                        ZStack {
//                            Image(uiImage: back)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .clipped()
//                            
//                            Image(uiImage: front)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .clipShape(DiagonalMask())
//                                .clipped()
//                        }
//                        
//                    case .corner:
//                        // Circular split (picture in picture)
//                        ZStack {
//                            Image(uiImage: back)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .clipped()
//                            
//                            Image(uiImage: front)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
//                        }
//                        
//                    case .circular:
//                        // Corner split
//                        ZStack {
//                            Image(uiImage: back)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .clipped()
//                            
//                            Image(uiImage: front)
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: geometry.size.width, height: geometry.size.height)
//                                .clipShape(CornerMask())
//                                .clipped()
//                        }
//                    }
//                } else {
//                    // Show loading or placeholder if no previews available
//                    VStack {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .scaleEffect(2)
//                        
//                        Text("Initializing camera...")
//                            .foregroundColor(.white)
//                            .padding(.top, 20)
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//
//struct CameraCapturePreview: UIViewRepresentable {
//    @ObservedObject var sessionManager: CaptureSessionManager
//    let cameraPosition: AVCaptureDevice.Position
//
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//        let previewLayer = AVCaptureVideoPreviewLayer()
//        previewLayer.session = sessionManager.session
//        previewLayer.videoGravity = .resizeAspectFill
//        // Configure connection for the specific cameraPosition
//        if let connection = previewLayer.connection,
//           let input = sessionManager.session?.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.position == cameraPosition }) as? AVCaptureDeviceInput {
//            sessionManager.session?.addConnection(AVCaptureConnection(inputPorts: input.ports, output: previewLayer))
//        }
//
//        view.layer.addSublayer(previewLayer)
//        return view
//    }
//
//    func updateUIView(_ uiView: UIView, context: Context) {
//        // Update layout or other properties if needed
//        if let previewLayer = uiView.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
//                 previewLayer.frame = uiView.bounds
//             }
//    }
//}
