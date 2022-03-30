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
//            theDashboardEntity.avgSpeed = 0
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
        MyLog.debug("prevLat: \(prevLat), prevLon: \(prevLon), newLat: \(newLat), newLon: \(newLon), DeltaX: \(deltaXY)")
        
        // update the total distance traveled
        distance += deltaXY
        
        // update the previous point to be the current point
        prevLat = newLat
        prevLon = newLon
                
        // save changes
        save()
    }

    
    //
    // MARK: Calculated Vars
    //
    public var wrappedStartTime: Date {
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

    public var elapsedSeconds: Int {
        get {
            Int(Date().timeIntervalSince1970 - wrappedStartTime.timeIntervalSince1970)
        }
    }

    // Return Metric or English units depending on settings
    // For Metric
    //    - Return Meters up to 1000 meters with no digits past the decimal
    //    - Return KM up if over 1000 meters with two digits past the decial
    // For British Units
    //    - Return Feet up to 1000 feet with no digits past the decimal
    //    - Return Miles if over 1000 feet with two diits past the decimal
    public func displayableOdometer() -> String {
        // Metric
        if AppSettingsEntity.getAppSettingsEntity().metricUnits {
            if distance < 1000 {
                return String(format: "%.0f Meters", distance)
            } else {
                // return Kilometers
                return String(format: "%.1f KM", distance/1000)
            }
        }
        // If we got this far then we're using Bristish Units
        let distanceInFeet = Utility.convertMetersToFeet(theMeters: distance)
        if distanceInFeet < 1000 {
            return String(format: "%.0f Feet", distanceInFeet)
        }
        let distanceInMiles = Utility.convertMetersToMiles(theMeters: distance)
        return String(format: "%.1f Miles", distanceInMiles)
    }

    
    // return the average speed in appropriate units
    public func displayableAvgSpeed() -> String {
        let avgSpeed = distance / Double(elapsedSeconds)
        return "\(avgSpeed) m/s"
    }
    
    // return start time to display
    public func displayableStartTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short // .medium
        let theStartTime = dateFormatter.string(from: wrappedStartTime)

        return theStartTime
    }
    
    // return elapsed time in appropriate units
    public func displayableElapsedTime() -> String {
        return "\(elapsedSeconds) Sec"
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


