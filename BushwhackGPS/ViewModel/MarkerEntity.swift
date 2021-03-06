//
//  MarkerEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 2/16/22.
//

import Foundation
import CoreData
import CoreGraphics // CGFloat is defined here
import UIKit // UIColor is defined here
import SwiftUI // Color is defined here

extension MarkerEntity: Comparable {
    public static func < (lhs: MarkerEntity, rhs: MarkerEntity) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
//        if (lhs.timestamp == nil) {return false}
//        if (rhs.timestamp == nil) {return true}
//        return lhs.timestamp! < rhs.timestamp!
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

    
    
    // Get array of all MarkerEntities (could be empty array)
    public static func getMarkersInDateRange(startDate: Date, endDate: Date) -> [MarkerEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<MarkerEntity>(entityName: "MarkerEntity")
        
//        Fix the predicate string
        request.predicate = NSPredicate(format: "timestamp >= %@ && timestamp <= %@", startDate as CVarArg, endDate as CVarArg)
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

    // Create a new MarkerEntity, save it and return it
    // Every field should be filled with a non-nil value
    @discardableResult public static func createMarkerEntity(lat: Double, lon: Double) -> MarkerEntity {
        let viewContext = PersistenceController.shared.container.viewContext
        let newMarker = MarkerEntity(context: viewContext)
        newMarker.id = ID_GeneratorEntity.getNextID()
        newMarker.sortOrder = newMarker.id
        newMarker.uuid = UUID()
        newMarker.timestamp = Date()
        newMarker.lat = lat
        newMarker.lon = lon
        newMarker.desc = ""
        newMarker.colorRed = 1.0
        newMarker.colorBlue = 0.0
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
    public var wrappedTitle: String {
        get {
            if title == nil {
                title = "Unnamed" // Must have a non blank name or the pop-up won't work
            }
            if title!.isEmpty {
                title = "" 
            }
            return title!
        }
        
        set { title = newValue } // by default the value passed into 'set' is named newValue
    }
    
    public var wrappedDesc: String {
        get { desc ?? "" }
        set { desc = newValue }
    }
    
    public var wrappedIconName: String {
        get { iconName ?? "triangle" }
        set { iconName = newValue }
    }

    public var wrappedTimeStamp: Date {
        get {
            if timestamp == nil {
                MyLog.debug("wdh *** ERROR *** This should NEVER happen - wrappedStartTime called for nil MarkerEntity timestamp")
                return Date()
            }
            return timestamp!
        }
        set {
            timestamp = newValue
        }
    }

    
    // Getter and Setter using Color type
    public var wrappedColor: Color {
        get {
            Color(.sRGB, red: colorRed, green: colorGreen, blue: colorBlue)
        }
        set {
            // Extract the RGB color values and save them in the Entity
            var rgbRed: CGFloat = 0
            var rgbBlue: CGFloat = 0
            var rgbGreen: CGFloat = 0
            var rgbAlpha: CGFloat = 0
            let myUIColor = UIColor(newValue)
            myUIColor.getRed(&rgbRed, green: &rgbGreen, blue: &rgbBlue, alpha: &rgbAlpha)
            colorRed = rgbRed
            colorBlue = rgbBlue
            colorGreen = rgbGreen
            colorAlpha = rgbAlpha // should always be 1.0 for display on map
        }
    }
    
    
    
}
