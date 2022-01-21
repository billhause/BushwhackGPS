//
//  ParkingSpotEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/18/22.
//

import Foundation
import CoreData

extension ParkingSpotEntity: Comparable {    // Making Comparable so that it can be used in a Map or Set
    
    // Needed for Comparable protocol - Sort by lat, then lon
    public static func < (lhs: ParkingSpotEntity, rhs: ParkingSpotEntity) -> Bool {
        if lhs.lat == rhs.lat {
            return lhs.lon < rhs.lon
        }
        return lhs.lat < rhs.lat
    }

    // Get one and only ParkingSpotEntity or create it if it doesn't exist yet
    public static func getParkingSpotEntity() -> ParkingSpotEntity {
        // see https://www.youtube.com/watch?v=yOhyOpXvaec at 39:30
        
        // Get the CoreData ViewContext
        let viewContext = PersistenceController.shared.container.viewContext
        
        let request = NSFetchRequest<ParkingSpotEntity>(entityName: "ParkingSpotEntity")
        
        // SortDescriptor and Predicate not needed since I'm retriveing the one and only record and not filtering the results
        //request.predicate = NSPredicate(format: "score > %@ AND score <%@", NSNumber(value: 3), NSNumber(value: 100))
        //let sortDesc = NSSortDescriptor(key: "score", ascending: true)
        //request.sortDescriptors = [sortDesc] // array of sort descriptors to use
        
        // Get array of results
        let results = try? viewContext.fetch(request) // should never fail
        
        // If we found one return it, otherwise create one and return it
        if let theParkingSpotEntity = results!.first { 
            // Found one so return it
            return theParkingSpotEntity
        } else {
            // No ParkingSpotEntity was found so create one, save it and return it
            let theParkingSpotEntity = ParkingSpotEntity(context: viewContext)
            theParkingSpotEntity.updateLocation(lat: 40.0, lon: -105.0, andSave: true) // default to 40,-105
//            theParkingSpotEntity.objectWillChange.send()
            return theParkingSpotEntity
        }
    }

    // Update the ParkingSpot location to the specified location and save it
    public func updateLocation(lat theLat: Double, lon theLon: Double, andSave shouldSave: Bool) {
        lat = theLat
        lon = theLon
        if shouldSave {
            // Now save the location to the database
            let viewContext = PersistenceController.shared.container.viewContext
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Wdh Error saving ParkingSpot \(nsError.userInfo)")
            }
        }
    }
}


