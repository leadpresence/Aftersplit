
import CoreData

// Core Data Models
extension CoreDataStorageService {
    func setupCoreDataModel() {
        let photoEntity = NSEntityDescription()
        photoEntity.name = "PhotoEntity"
        photoEntity.managedObjectClassName = "PhotoEntity"
        
        let photoIdAttribute = NSAttributeDescription()
        photoIdAttribute.name = "id"
        photoIdAttribute.attributeType = .UUIDAttributeType
        photoIdAttribute.isOptional = false
        
        let photoFrontImageAttribute = NSAttributeDescription()
        photoFrontImageAttribute.name = "frontImage"
        photoFrontImageAttribute.attributeType = .binaryDataAttributeType
        photoFrontImageAttribute.isOptional = false
        
        let photoBackImageAttribute = NSAttributeDescription()
        photoBackImageAttribute.name = "backImage"
        photoBackImageAttribute.attributeType = .binaryDataAttributeType
        photoBackImageAttribute.isOptional = false
        
        let photoTimestampAttribute = NSAttributeDescription()
        photoTimestampAttribute.name = "timestamp"
        photoTimestampAttribute.attributeType = .dateAttributeType
        photoTimestampAttribute.isOptional = false
        
        let photoFilterAttribute = NSAttributeDescription()
        photoFilterAttribute.name = "filter"
        photoFilterAttribute.attributeType = .stringAttributeType
        photoFilterAttribute.isOptional = true
        
        photoEntity.properties = [
            photoIdAttribute,
            photoFrontImageAttribute,
            photoBackImageAttribute,
            photoTimestampAttribute,
            photoFilterAttribute
        ]
        
        let videoEntity = NSEntityDescription()
        videoEntity.name = "VideoEntity"
        videoEntity.managedObjectClassName = "VideoEntity"
        
        let videoIdAttribute = NSAttributeDescription()
        videoIdAttribute.name = "id"
        videoIdAttribute.attributeType = .UUIDAttributeType
        videoIdAttribute.isOptional = false
        
        let videoUrlStringAttribute = NSAttributeDescription()
        videoUrlStringAttribute.name = "urlString"
        videoUrlStringAttribute.attributeType = .stringAttributeType
        videoUrlStringAttribute.isOptional = false
        
        let videoDurationAttribute = NSAttributeDescription()
        videoDurationAttribute.name = "duration"
        videoDurationAttribute.attributeType = .doubleAttributeType
        videoDurationAttribute.isOptional = false
        
        let videoTimestampAttribute = NSAttributeDescription()
        videoTimestampAttribute.name = "timestamp"
        videoTimestampAttribute.attributeType = .dateAttributeType
        videoTimestampAttribute.isOptional = false
        
        let videoFilterAttribute = NSAttributeDescription()
        videoFilterAttribute.name = "filter"
        videoFilterAttribute.attributeType = .stringAttributeType
        videoFilterAttribute.isOptional = true
        
        videoEntity.properties = [
            videoIdAttribute,
            videoUrlStringAttribute,
            videoDurationAttribute,
            videoTimestampAttribute,
            videoFilterAttribute
        ]
        
        let model = NSManagedObjectModel()
        model.entities = [photoEntity, videoEntity]
        
        let container = NSPersistentContainer(name: "AfterSplit", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
}
