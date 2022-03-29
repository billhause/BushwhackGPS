//
//  DashboardEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/29/22.
//

import Foundation
import CoreData
import SwiftUI

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
            theDashboardEntity.prevLat = 181 // Indicates not initialized yet - Get Distance will return 0 for invalid lat/lon
            theDashboardEntity.prevLon = 181 // Indicates not initialized yet
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("wdh Unresolved error saving DashboardEntity: \(nsError), \(nsError.userInfo)")
            }
            return theDashboardEntity
        }
    }
    
    // Delete a Dashboard object
    static func deleteDashboardEntity(_ theDashboardEntity: DashboardEntity) {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(theDashboardEntity)
    }

    
    //
    // Member Functions
    //
    
    // Update the dashboard values
    //   - avg speed
    //   - total distance traveled
    //   - point count
    //   -
    public func updateDashboardEntity(newLat: Double, newLon: Double) {
        
        // get delta distance
        let deltaXY = Utility.getDistanceInMeters(lat1: newLat, lon1: newLon, lat2: prevLat, lon2: prevLon)
        MyLog.debug("DeltaX: \(deltaXY)")
        
        // update the total distance traveled
        distance += deltaXY
        
        // get the current time
        
        // update the total elapse time
        deltaSeconds = Date().timeIntervalSince1970 = startTime?.timeIntervalSince1970
        
        
        // save changes
    }

    
    
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
    public func displayableAvgSpeed() -> String {
        return "3.6 MPH"
    }
    
    // return the odometer reading in appropriate units
    public func displayableOdometer() -> String {
        return "2.4 Miles"
    }
    
    // return start time to display
    public func displayableStartTime() -> String {
        return "3/29/2022 3:46pm"
    }
    
    // return elapse time in appropriate units
    public func displayableElapseTime() -> String {
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


