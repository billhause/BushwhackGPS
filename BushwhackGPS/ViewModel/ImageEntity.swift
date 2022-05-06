//
//  ImageEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 4/5/22.
//

import Foundation
import CoreData
import UIKit

extension ImageEntity: Comparable {
    public static func < (lhs: ImageEntity, rhs: ImageEntity) -> Bool {
        if (lhs.timeStamp == nil) {return false}
        if (rhs.timeStamp == nil) {return true}
        return lhs.timeStamp! < rhs.timeStamp!
    }
    
    
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

    public static func getAllImageEntitiesForMarker(theMarker: MarkerEntity) -> [ImageEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
        request.predicate = NSPredicate(format: "marker = %@", theMarker)
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
    
    
    //
    // MARK: Member Functions
    //
    
    
    
    // Set image and save the database
    func setImageAndSave(_ theUIImage: UIImage) {
        imageData = theUIImage.jpegData(compressionQuality: 0.25) // 1.0 = No Compression, 0.0=MAX COMPRESSION Worst Quality
        // imageData = theUIImage.pngData() // DO NOT USE PNG - WAY TOO BIG AND SLOW
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("wdh ImageEntity.setImageAndSave(): Error Saving Image to Core Data \(nsError.userInfo)")
        }
    }
    
    // Get the UIImage from the ImageEntity in Core Data
    func getUIImage() -> UIImage {
        // imageData will be nil if the ImageEntity was never loaded with an image yet
        if imageData == nil {
            return UIImage() // Return a new empty UIImage if ImageEntity.imageData is nil
        }
        
        if let theUIImage = UIImage(data: imageData!) {
            return theUIImage
        }
        
        // Should not reach this unless an error happend creating the UIImage above
        print("ERROR wdh Somehow we failed to create the UIImage from the raw imageData in getImage()")
        return UIImage() // Should never get here but if we do, then just return an empty UIImage
    }

}






