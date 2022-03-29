//
//  DashboardEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/29/22.
//

import Foundation
import CoreData

extension DashboardEntity {
    
    // Get the One and ONLY Dashboard Entity or create one if it doesn't exist
    public static func getDashboardEntity() -> DashboardEntity {
        let context = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<DashboardEntity>(entityName: "DashboardEntity")
        
        // SortDescriptor and Predicate are not needed since I'm retriveing the one and only record and not filtering the results

        // Get Array of Results
        let results = try? context.fetch(request) // Should never fail
        
        // If we found one, return it.  Otherwise create one, save it and return it
        if let theDashboardEntity = results!.first {
            // Found one so return it
            return theDashboardEntity
        } else {
            let theDashboardEntity = DashboardEntity(context: context)
            // avgSpeed, distance, pointCount and startTime
            theDashboardEntity.avgSpeed = 0
            theDashboardEntity.distance = 0
            theDashboardEntity.pointCount = 0
            theDashboardEntity.startTime = Date()
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("wdh Unresolved error saving DashboardEntity: \(nsError), \(nsError.userInfo)")
            }
            return theDashboardEntity
        }
    }
    
    //
    // Member Functions
    //
    
    public var wrappedDate: Date {
        get {
            if startTime == nil {
                MyLog.debug("ERROR - Dashboard StartTime is nil - This should NEVER HAPPEN")
                return Date()
            }
            return startTime!
        }
        set {
            startTime = newValue
        }
    }
    
    // return the average speed in appropriate units
    public func displayAvgSpeed() -> String {
        return "3.6 MPH"
    }
    
    // return the odometer reading in appropriate units
    public func displayOdometer() -> String {
        return "2.4 Miles"
    }
    
    // return start time to display
    public func displayStartTime() -> String {
        return "3/29/2022 3:46pm"
    }
    
    // return elapse time in appropriate units
    public func displayElapseTime() -> String {
        return "3:27:46"
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

    
}


