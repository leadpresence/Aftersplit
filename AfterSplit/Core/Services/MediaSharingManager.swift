//
//  MediaSharingManager.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//

import Photos
import UIKit

class MediaSharingManager {
    static let shared = MediaSharingManager()
    
    private init() {}
    
    func savePhotoToLibrary(frontImage: Data, backImage: Data, splitStyle: SplitStyle, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "com.aftersplit.error", code: 7, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"])))
                return
            }
            
            // Create a combined image based on split style
            guard let frontUIImage = UIImage(data: frontImage),
                  let backUIImage = UIImage(data: backImage) else {
                completion(.failure(NSError(domain: "com.aftersplit.error", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to process images"])))
                return
            }
            
            let combinedImage = self.combineImages(front: frontUIImage, back: backUIImage, style: splitStyle)
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: combinedImage.jpegData(compressionQuality: 0.9) ?? Data(), options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "com.aftersplit.error", code: 9, userInfo: [NSLocalizedDescriptionKey: "Failed to save photo"])))
                    }
                }
            }
        }
    }
    
    func saveVideoToLibrary(videoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "com.aftersplit.error", code: 10, userInfo: [NSLocalizedDescriptionKey: "Photo library access denied"])))
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: videoURL, options: nil)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "com.aftersplit.error", code: 11, userInfo: [NSLocalizedDescriptionKey: "Failed to save video"])))
                    }
                }
            }
        }
    }
    
    func shareMedia(image: UIImage?, videoURL: URL?, fromViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        var items: [Any] = []
        
        if let image = image {
            items.append(image)
        }
        
        if let videoURL = videoURL {
            items.append(videoURL)
        }
        
        guard !items.isEmpty else {
            completion(false)
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { _, success, _, _ in
            completion(success)
        }
        
        // For iPad support
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = fromViewController.view
            popoverController.sourceRect = CGRect(x: fromViewController.view.bounds.midX, y: fromViewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        fromViewController.present(activityViewController, animated: true)
    }
    
    private func combineImages(front: UIImage, back: UIImage, style: SplitStyle) -> UIImage {
        let size = CGSize(width: max(front.size.width, back.size.width),
                         height: max(front.size.height, back.size.height))
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw background image
        let backRect = CGRect(origin: .zero, size: size)
        back.draw(in: backRect)
        
        // Apply mask based on split style
        context.saveGState()
        
        switch style {
        case .straight:
            // Draw front image on right half
            let frontRect = CGRect(x: size.width/2, y: 0, width: size.width/2, height: size.height)
            front.draw(in: frontRect)
            
        case .diagonal:
            // Create diagonal mask
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
            
            context.addPath(path)
            context.clip()
            front.draw(in: CGRect(origin: .zero, size: size))
            
        case .circular:
            // Create circular mask
            let circleDiameter = min(size.width, size.height) * 0.4
            let circleRect = CGRect(
                x: size.width * 0.8 - circleDiameter/2,
                y: size.height * 0.2 - circleDiameter/2,
                width: circleDiameter,
                height: circleDiameter
            )
            
            context.addEllipse(in: circleRect)
            context.clip()
            front.draw(in: CGRect(origin: .zero, size: size))
            
        case .corner:
            // Create corner mask
            let path = CGMutablePath()
            path.move(to: CGPoint(x: size.width - size.width/3, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: 0))
            path.addLine(to: CGPoint(x: size.width, y: size.height/3))
            path.closeSubpath()
            
            context.addPath(path)
            context.clip()
            front.draw(in: CGRect(origin: .zero, size: size))
        }
        
        context.restoreGState()
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
} 
