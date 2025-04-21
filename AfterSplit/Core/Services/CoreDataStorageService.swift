
// 2.5 Storage Service Implementation
//import CoreData
//
//class CoreDataStorageService: StorageServiceProtocol {
//    func saveVideo(_ video: Video) async throws {
//        return try await withCheckedThrowingContinuation { continuation in
//            backgroundContext.perform {
//                do {
//                    let videoEntity = VideoEntity(context: self.backgroundContext)
//                    videoEntity.id = video.id
//                    videoEntity.urlString = video.url.absoluteString
//                    videoEntity.duration = video.duration
//                    videoEntity.timestamp = video.timestamp
//                    videoEntity.filter = video.appliedFilter?.ciFilterName()
//                    try self.backgroundContext.save()
//                    continuation.resume()
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//            
//        }
//    }
//    
//    private let container: NSPersistentContainer
//    private let backgroundContext: NSManagedObjectContext
//    
//    init() {
//        container = NSPersistentContainer(name: "AfterSplit")
//        container.loadPersistentStores { _, error in
//            if let error = error {
//                fatalError("Failed to load Core Data stack: \(error)")
//            }
//        }
//        backgroundContext = container.newBackgroundContext()
//    }
//    
//    func savePhoto(_ photo: Photo) async throws {
//        return try await withCheckedThrowingContinuation { continuation in
//            backgroundContext.perform {
//                do {
//                    let photoEntity = PhotoEntity(context: self.backgroundContext)
//                    photoEntity.id = photo.id
//                    photoEntity.frontImage = photo.frontImage
//                    photoEntity.backImage = photo.backImage
//                    photoEntity.timestamp = photo.timestamp
//                    photoEntity.filter = photo.appliedFilter?.ciFilterName()?.lowercased()
//                    
//                    try self.backgroundContext.save()
//                    continuation.resume()
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
////    
////    func saveVideo(_ video: Video) async throws {
////        return try await withCheckedThrowingContinuation { continuation in
////            backgroundContext.perform {
////                do {
////                    let videoEntity = VideoEntity(context: self.backgroundContext)
////                    videoEntity.id = video.id
////                    videoEntity.urlString = video.url.absoluteString
////                    videoEntity.duration = video.duration
////                    videoEntity.timestamp = video.timestamp
////                    videoEntity.filter = video?.appliedFilter.mono
////                    
////                    try self.backgroundContext.save()
////                    continuation.resume()
////                } catch {
////                    continuation.resume(throwing: error)
////                }
////            }
////        }
////    }
//    
//    func fetchPhotos() async throws -> [Photo] {
//        return try await withCheckedThrowingContinuation { continuation in
//            backgroundContext.perform {
//                do {
//                    let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PhotoEntity.timestamp, ascending: false)]
//                    
//                    let photoEntities = try self.backgroundContext.fetch(fetchRequest)
//                    let photos = photoEntities.compactMap { entity -> Photo? in
//                        guard let id = entity.id,
//                              let frontImage = entity.frontImage,
//                              let backImage = entity.backImage,
//                              let timestamp = entity.timestamp else {
//                            return nil
//                        }
//                        
//                        let filter = entity.filter.flatMap { Filter(rawValue: $0) }
//                        
//                        return Photo(
//                            id: id,
//                            frontImage: frontImage,
//                            backImage: backImage,
//                            timestamp: timestamp,
//                            appliedFilter: filter
//                        )
//                    }
//                    
//                    continuation.resume(returning: photos)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    func fetchVideos() async throws -> [Video] {
//        return try await withCheckedThrowingContinuation { continuation in
//            backgroundContext.perform {
//                do {
//                    let fetchRequest: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
//                    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \VideoEntity.timestamp, ascending: false)]
//                    
//                    let videoEntities = try self.backgroundContext.fetch(fetchRequest)
//                    let videos = videoEntities.compactMap { entity -> Video? in
//                        guard let id = entity.id,
//                              let urlString = entity.urlString,
//                              let url = URL(string: urlString),
//                              let timestamp = entity.timestamp else {
//                            return nil
//                        }
//                        
//                        let filter = entity.filter.flatMap { Filter(rawValue: $0) }
//                        
//                        return Video(
//                            id: id,
//                            url: url,
//                            duration: entity.duration,
//                            timestamp: timestamp,
//                            appliedFilter: filter ?? <#default value#>
//                        )
//                    }
//                    
//                    continuation.resume(returning: videos)
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    func deletePhoto(id: UUID) async throws {
//        return try await withCheckedThrowingContinuation { continuation in
//            backgroundContext.perform {
//                do {
//                    let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
//                    fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//                    
//                    if let photoEntity = try self.backgroundContext.fetch(fetchRequest).first {
//                        self.backgroundContext.delete(photoEntity)
//                        try self.backgroundContext.save()
//                    }
//                    
//                    continuation.resume()
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//    
//    func deleteVideo(id: UUID) async throws {
//        return try await withCheckedThrowingContinuation { continuation in
//            backgroundContext.perform {
//                do {
//                    let fetchRequest: NSFetchRequest<VideoEntity> = VideoEntity.fetchRequest()
//                    fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//                    
//                    if let videoEntity = try self.backgroundContext.fetch(fetchRequest).first {
//                        self.backgroundContext.delete(videoEntity)
//                        try self.backgroundContext.save()
//                    }
//                    
//                    continuation.resume()
//                } catch {
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//}
