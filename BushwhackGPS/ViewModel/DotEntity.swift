//
//  DotEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/23/22.
//

import Foundation
import CoreData

extension DotEntity: Comparable {
    public static func < (lhs: DotEntity, rhs: DotEntity) -> Bool {
        if (lhs.timestamp == nil) {return false}
        if (rhs.timestamp == nil) {return true}
        return lhs.timestamp! < rhs.timestamp!
    }

    // Get array of all DotEntitys.
    public static func getAllDotEntities() -> [DotEntity] {
        
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<DotEntity>(entityName: "DotEntity")
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sortDesc]
        
        // Get array of sorted results
        do {
            let results = try viewContext.fetch(request)
            MyLog.debug("getAllDotEntities Loaded \(results.count) DotEntities")
            return results
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error loading DotEntity Array in getAllDots() \(nsError.userInfo)")
        }
        
        // If we got this far then we had an error getting the DotEntity array so return empty array
        return []
    }
    
    
    // Create a new DotEntity, save it and return it
    @discardableResult public static func createDotEntity(lat: Double, lon: Double, speed: Double, course: Double) -> DotEntity {
        let viewContext = PersistenceController.shared.container.viewContext
        let newDot = DotEntity(context: viewContext)
        newDot.id = ID_GeneratorEntity.getNextID()
        newDot.uuid = UUID()
        newDot.timestamp = Date()
        newDot.lat = lat
        newDot.lon = lon
        newDot.speed = speed
        newDot.course = course
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving new DotEntity in createDot() \(nsError.userInfo)")
        }
        return newDot
    }
    
    // Delete a DotEntity object
    static func deleteDotEntity(_ theDotEntity: DotEntity) {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(theDotEntity)
    }
    
}
