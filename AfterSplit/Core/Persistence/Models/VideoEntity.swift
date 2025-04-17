//
//  VideoEntity.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//


import SwiftUI
import CoreData


class VideoEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var urlString: String?
    @NSManaged var duration: Double
    @NSManaged var timestamp: Date?
    @NSManaged var filter: String?
    
    static func fetchRequest() -> NSFetchRequest<VideoEntity> {
        return NSFetchRequest<VideoEntity>(entityName: "VideoEntity")
    }
}
