////
////  CoreDataManager.swift
////  AfterSplit
////
////  Created by Kehinde Akeredolu on 18/04/2025.
////
//
//import Foundation
//import CoreData
//
//class CoreDataManager {
//    static let shared = CoreDataManager()
//    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "AfterSplit")
//        container.loadPersistentStores { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        }
//        return container
//    }()
//    
//    var context: NSManagedObjectContext {
//        return persistentContainer.viewContext
//    }
//    
//    func saveContext() {
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                print("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
//    
//    // MARK: - Photo Operations
//    func savePhoto(photo: Photo) throws {
//        let entity = PhotoEntity(context: context)
//        entity.id = photo.id
//        entity.frontImageData = photo.frontImage
//        entity.backImageData = photo.backImage
//        entity.timestamp = photo.timestamp
//        entity.filterType = photo.appliedFilter.rawValue
//        entity.splitStyle = photo.splitStyle.rawValue
//        
//        try context.save()
//    }
//    
//    func getAllPhotos() throws -> [Photo] {
//        let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
//        
//        let entities = try context.fetch(fetchRequest)
//        
//        return entities.compactMap { entity in
//            guard let id = entity.id,
//                  let frontData = entity.frontImageData,
//                  let backData = entity.backImageData,
//                  let timestamp = entity.timestamp,
//                  let filterTypeString = entity.filterType,
//                  let splitStyleString = entity.splitStyle,
//                  let filterType = Filter(rawValue: filterTypeString),
//                  let splitStyle = SplitStyle(rawValue: splitStyleString) else {
//                return nil
//            }
//            
//            var photo = Photo(id: id, frontImage: frontData, backImage: backData, timestamp: timestamp, appliedFilter: filterType)
//            photo.splitStyle = splitStyle
//            return photo
//        }
//    }
//    
//    func deletePhoto(id: UUID) throws {
//        let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//        
//        let entities = try context.fetch(fetchRequest)
//        
//        for entity in entities {
//            context.delete(entity)
//        }
//        
//        try context.save()
//    }
//    
//    // MARK: - Video Operations
//    func saveVideo(video: Video) throws {
//        let entity = VideoEntity(context: context)
//        entity.id = video.id
//        entity.urlString = video.url.absoluteString
//        entity.duration = video.duration
//        entity.timestamp = video.timestamp
//        entity.filterType = video.appliedFilter.rawValue
//        entity.splitStyle = video.splitStyle.rawValue
//        
//        try context.save()
//    }
//    
//    func getAllVideos() throws -> [Video] {
//        let fetchRequest: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
//        
//        let entities = try context.fetch(fetchRequest)
//        
//        return entities.compactMap { entity in
//            guard let id = entity.id,
//                  let urlString = entity.urlString,
//                  let url = URL(string: urlString),
//                  let timestamp = entity.timestamp,
//                  let filterTypeString = entity.filterType,
//                  let splitStyleString = entity.splitStyle,
//                  let filterType = Filter(rawValue: filterTypeString),
//                  let splitStyle = SplitStyle(rawValue: splitStyleString) else {
//                return nil
//            }
//            
//            var video = Video(id: id, url: url, duration: entity.duration, timestamp: timestamp, appliedFilter: filterType)
//            video.splitStyle = splitStyle
//            return video
//        }
//    }
//    
//    func deleteVideo(id: UUID) throws {
//        let fetchRequest: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//        
//        let entities = try context.fetch(fetchRequest)
//        
//        for entity in entities {
//            context.delete(entity)
//        }
//        
//        try context.save()
//    }
//}
