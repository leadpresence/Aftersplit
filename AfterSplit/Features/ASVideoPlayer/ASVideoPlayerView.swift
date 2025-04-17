//
//  VideoPlayerView.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//

import SwiftUI
import AVKit
import AVFoundation
//Value of type 'AVPlayerViewControllerRepresentable' has no member 'edgesIgnoringSafeArea'
//Cannot infer contextual base in reference to member 'all'

struct ASVideoPlayerView: View {
    let video: Video
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
           NavigationView {
               ZStack {
                   // Background color for areas not covered by video
                   Color.black
                       .edgesIgnoringSafeArea(.all)
                   
                   // Video player
                   VideoPlayer(player: AVPlayer(url: video.url))
                       .aspectRatio(16/9, contentMode: .fit)
               }
               .navigationBarItems(
                   leading: Button(action: {
                       presentationMode.wrappedValue.dismiss()
                   }) {
                       Text("Close")
                           .foregroundColor(.white)
                   },
                   trailing: Button(action: {
                       shareVideo()
                   }) {
                       Image(systemName: "square.and.arrow.up")
                           .foregroundColor(.white)
                   }
               )
               .navigationBarTitleDisplayMode(.inline)
           }
           .navigationViewStyle(StackNavigationViewStyle())
       }
    
//    var body: some View {
//        NavigationView {
//            AVPlayerViewControllerRepresentable(url: video.url)
//                .edgesIgnoringSafeArea(.all)
//                .navigationBarItems(
//                    leading: Button(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Text("Close")
//                            .foregroundColor(.white)
//                    },
//                    trailing: Button(action: {
//                        shareVideo()
//                    }) {
//                        Image(systemName: "square.and.arrow.up")
//                            .foregroundColor(.white)
//                    }
//                )
//                .navigationBarTitleDisplayMode(.inline)
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
    
    private func shareVideo() {
        // Use UIApplication.shared.windows.first?.rootViewController to get a reference to the root view controller
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        MediaSharingManager.shared.shareMedia(
            image: nil,
            videoURL: video.url,
            fromViewController: rootViewController
        ) { success in
            print("Video share completed with success: \(success)")
        }
    }
}
