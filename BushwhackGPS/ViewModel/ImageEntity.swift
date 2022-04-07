//
//  ImageEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 4/5/22.
//

import Foundation
import CoreData

extension ImageEntity: Comparable {
    public static func < (lhs: ImageEntity, rhs: ImageEntity) -> Bool {
        if (lhs.timeStamp == nil) {return false}
        if (rhs.timeStamp == nil) {return true}
        return lhs.timeStamp! < rhs.timeStamp!
    }
    
    // TODO: Get array of All ImageEntites for a specific MarkerEntity
    
    
    // Get array of ALL ImageEntities
    public static func getAllImageEntities() -> [ImageEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
        let sortDesc = NSSortDescriptor(key: "timeStamp", ascending: false) // Newest at top
        request.sortDescriptors = [sortDesc]
        
        // Get array of sorted results
        do {
            let results = try viewContext.fetch(request)
            return results
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error loading ImageEntity Array in getAllImageEntities() \(nsError.userInfo)")
        }
        
        // If we got this far then we had an error getting the ImageEntity array so return an empty array
        return []
    }
    
    // Create a new ImageEntity, save it and return it
    @discardableResult public static func createImageEntity(theMarkerEntity: MarkerEntity) -> ImageEntity {
        let viewContext = PersistenceController.shared.container.viewContext
        let newImage = ImageEntity(context: viewContext)
        newImage.timeStamp = Date()
        newImage.uuid = UUID()
        newImage.imageData = nil
        newImage.marker = theMarkerEntity
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error in createImageEntity() \(nsError.userInfo)")
        }
        return newImage
    }
    
    // Delete an ImageEntity object
    static func deleteImageEntity(_ theImageEntity: ImageEntity) {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(theImageEntity)
    }
    
}

Next add a button to the MarkerView to load an image.  Then create an imageEntity for the current Marker -- See the demo app for sample code



