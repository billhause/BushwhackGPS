//
//  AppSettingsEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/13/22.
//

import Foundation
import CoreData

extension AppSettingsEntity {
    static let REVIEW_THRESHOLD = 4 // Number of app activations needed to trigger a review request

    // Get the One and Only AppSettingsEntity or create one if it doesn't exist
    public static func getAppSettingsEntity() -> AppSettingsEntity {
        let context = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<AppSettingsEntity>(entityName: "AppSettingsEntity")
        
        // SortDescriptor and Predicate are not needed since I'm retriveing the one and only record and not filtering the results
        //request.predicate = NSPredicate(format: "score > %@ AND score <%@", NSNumber(value: 3), NSNumber(value: 100))
        //let sortDesc = NSSortDescriptor(key: "score", ascending: true)
        //request.sortDescriptors = [sortDesc] // array of sort descriptors to use

        // Get Array of Results
        let results = try? context.fetch(request) // should never fail
        
        // If we found one, return it.  Otherwise, create one, save it and return it
        if let theAppSettingsEntity = results!.first {
            // Found one so return it
            return theAppSettingsEntity
        } else {
            let theAppSettingsEntity = AppSettingsEntity(context: context)
            theAppSettingsEntity.orientNorth = false // default to orient in direction phone is pointing
            theAppSettingsEntity.metricUnits = false // default to English Units
            theAppSettingsEntity.nextDotColorIndex = 0 // keep track of the dot color to use next
            theAppSettingsEntity.gasPrice = 4.0 // Default to $4 per gallon
            theAppSettingsEntity.mpg = 20  // average mpg for cars / suvs
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error saving AppSettingsEntity: \(nsError), \(nsError.userInfo)")
            }
            return theAppSettingsEntity
        }
    }
    
    public func getOrientNorth() -> Bool {
        return orientNorth
    }
    
    public func setOrientNorth(always: Bool) {
        orientNorth = always
        save()
    }
    

    public func save() {
        let context = PersistenceController.shared.container.viewContext
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error saving AppSettingsEntity: \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    // Increment Usage Count
    public func incrementUsageCount() {
        usageCount += 1
        save()
    }

    
}
