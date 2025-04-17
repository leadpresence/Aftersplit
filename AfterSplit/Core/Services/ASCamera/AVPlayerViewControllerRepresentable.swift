//
//  AVPlayerViewControllerRepresentable.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//
import SwiftUI
import AVKit
import Foundation

struct AVPlayerViewControllerRepresentable: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
