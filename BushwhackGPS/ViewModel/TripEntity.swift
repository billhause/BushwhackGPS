//
//  TripEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/15/22.
//

import Foundation
import CoreData

extension TripEntity: Comparable {
    public static func < (lhs: TripEntity, rhs: TripEntity) -> Bool {
        if (lhs.startTime == nil) {return false}
        if (rhs.startTime == nil) {return false}
        return lhs.startTime! < rhs.startTime!
    }
    
    // Get array of all TripEntities (could be an empty array)
    public static func getAllTripEntities() -> [TripEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        let sortDesc = NSSortDescriptor(key: "startTime", ascending: true)
        request.sortDescriptors = [sortDesc]
        
        // Get array of sorted results
        do {
            let results = try viewContext.fetch(request)
            return results
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error loading TripEnties in getAllTripEntities() \(nsError.userInfo)")
        }
        
        // If we got this far then we had an error getting the TripEntity array so return an empty array
        return []
    }
    
    
    
    /*
     title String
     desc String
     dotColorAlpha Double
     dotColorBlue Double
     dotColorRed Double
     dotColorGreen Double
     dotSize Double
     endTime Date
     startTime Date
     uuid UUID
     id Int64
     */
    
    // Create a new TripEntity, save it and return it
    // Every field will be filled with a non-nil value except startTime and endTime
    @discardableResult public static func createTripEntity() -> TripEntity {
        let viewContext = PersistenceController.shared.container.viewContext
        let newTrip = TripEntity(context: viewContext)
        newTrip.id = ID_GeneratorEntity.getNextID()
        newTrip.uuid = UUID()
        newTrip.desc = ""
        newTrip.dotColorRed = 0.0
        newTrip.dotColorBlue = 0.0
        newTrip.dotColorGreen = 1.0
        newTrip.dotColorAlpha = 1.0
        newTrip.dotSize = 3.0
        newTrip.endTime = nil
        newTrip.startTime = nil
        
        // use createion date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        newTrip.title = dateFormatter.string(from: Date())
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error creating TripEntity in createTripEntity() \(nsError.userInfo)")
        }
        return newTrip
    }
    
    // Delete a TripEntity object
    static func deleteTripEntity(_ theTripEntity: TripEntity) {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(theTripEntity)
    }
    
    // MARK: Member Functions
    
    func save() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving TripEntity in call to member func 'save()' \(nsError.userInfo)")
        }
    }
    
}
