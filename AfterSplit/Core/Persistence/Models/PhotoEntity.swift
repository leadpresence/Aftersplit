//
//  PhotoEntity.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//
import SwiftUI
import CoreData

class PhotoEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var frontImage: Data?
    @NSManaged var backImage: Data?
    @NSManaged var timestamp: Date?
    @NSManaged var filter: String?
    
    static func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }
}
