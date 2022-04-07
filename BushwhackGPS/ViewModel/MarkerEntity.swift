//
//  MarkerEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 2/16/22.
//

import Foundation
import CoreData

extension MarkerEntity: Comparable {
    public static func < (lhs: MarkerEntity, rhs: MarkerEntity) -> Bool {
        if (lhs.timestamp == nil) {return false}
        if (rhs.timestamp == nil) {return true}
        return lhs.timestamp! < rhs.timestamp!
    }
    
    // Get array of all MarkerEntities (could be empty array)
    public static func getAllMarkerEntities() -> [MarkerEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<MarkerEntity>(entityName: "MarkerEntity")
        let sortDesc = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sortDesc]
        
        // Get array of sorted results
        do {
            let results = try viewContext.fetch(request)
            return results
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error loading MarkerEntities in getAllMarkerEntities() \(nsError.userInfo)")
        }
        
        // If we got this far then we had an error getting the MarkerEntity array so return an empty array
        return []
    }
    
    Next create the ImageEntity extensions class
    
    // Create a new MarkerEntity, save it and return it
    // Every field should be filled with a non-nil value
    @discardableResult public static func createMarkerEntity(lat: Double, lon: Double) -> MarkerEntity {
        let viewContext = PersistenceController.shared.container.viewContext
        let newMarker = MarkerEntity(context: viewContext)
        newMarker.id = ID_GeneratorEntity.getNextID()
        newMarker.uuid = UUID()
        newMarker.timestamp = Date()
        newMarker.lat = lat
        newMarker.lon = lon
        newMarker.desc = "wdh"
        newMarker.colorRed = 0.0
        newMarker.colorBlue = 1.0
        newMarker.colorGreen = 0.0
        newMarker.colorAlpha = 1.0
        newMarker.iconName = "triangle" // default shape name to use for the map annotation
        
        // Use creation date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short // .medium
        newMarker.title = dateFormatter.string(from: newMarker.timestamp!)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving new MarkerEntity in createMarkerEntity() \(nsError.userInfo)")
        }
        return newMarker
    }
    
    
    // Delete a MarkerEntity object
    static func deleteMarkerEntity(_ theMarkerEntity: MarkerEntity) {
        let viewContext = PersistenceController.shared.container.viewContext
        MyLog.debug("deleteMarkerEntity: About to delete MarkerID \(theMarkerEntity.id)")
        viewContext.delete(theMarkerEntity)
        saveAll() // Save the viewContext with the Marker deleted
        MyLog.debug("deleteMarkerEntity - Just called viewContext.delete(theMarkerEntity)")
    }

    static func saveAll() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving new MarkerEntity in call to member func 'save()' \(nsError.userInfo)")
        }
    }

    // MARK: Member Functions
    
    
}
