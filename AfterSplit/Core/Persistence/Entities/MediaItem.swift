//
//  MediaItem.swift
//  AfterSplit
//
//  Created by Kehinde Akeredolu on 21/04/2025.
//
import SwiftUI

struct MediaItem: Identifiable, Equatable {
    let id: UUID
    let url: URL
    let thumbnailUrl: URL?
    let type: MediaType
    let timestamp: Date
    
    enum MediaType {
        case photo
        case video
    }
}
