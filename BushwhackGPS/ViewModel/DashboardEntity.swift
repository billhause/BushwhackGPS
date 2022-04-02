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
            theDashboardEntity.distance = 0 // meters
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

    // Reset to current time, 0 distance
    public func resetDashboard() {
        distance = 0
        startTime = Date() // current time
        
        // invalid lat/lon values will trigger a new start distance of 0
        prevLat = 181
        prevLon = 181
    }
    

    // Update the dashboard values
    //   - avg speed
    //   - total distance traveled
    //   - point count
    //   -
    public func updateDashboardEntity(newLat: Double, newLon: Double) {
        
        // get delta distance
        let deltaXY = Utility.getDistanceInMeters(lat1: newLat, lon1: newLon, lat2: prevLat, lon2: prevLon)
        
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
        return Utility.getDisplayableDistance(useMetricUnits: AppSettingsEntity.getAppSettingsEntity().metricUnits,
                                              meters: distance)
//        // Metric
//        if AppSettingsEntity.getAppSettingsEntity().metricUnits {
//            if distance < 1000 {
//                return String(format: "%.0f Meters", distance)
//            } else {
//                // return Kilometers
//                return String(format: "%.1f KM", distance/1000)
//            }
//        }
//        // If we got this far then we're using Bristish Units
//        let distanceInFeet = Utility.convertMetersToFeet(theMeters: distance)
//        if distanceInFeet < 1000 {
//            return String(format: "%.0f Feet", distanceInFeet)
//        }
//        let distanceInMiles = Utility.convertMetersToMiles(theMeters: distance)
//        return String(format: "%.1f Miles", distanceInMiles)
    }

    
    // return the average speed in appropriate units
    // MPH or "km/h"
    // 3600 Seconds Per Hour
    public func displayableAvgSpeed() -> String {
        return Utility.getDisplayableSpeed(useMetricUnits: AppSettingsEntity.getAppSettingsEntity().metricUnits,
                                           meters: distance,
                                           seconds: Int64(elapsedSeconds))
//
//        // Metric (km/h)
//        if AppSettingsEntity.getAppSettingsEntity().metricUnits {
//            let km = distance/1000 // convert meters to km
//            let hours = Double(elapsedSeconds) / 3600.0       // 3600 seconds per hour
//            var speed_km_per_hour = 0.0 // default to 0 if hours is 0
//            if hours > 0.0 {
//                speed_km_per_hour = km / hours
//            }
//            return String(format: "%.1f km/h", speed_km_per_hour)
//        }
//
//        // If we got this far then we're using Bristish Units (MPH)
//        let miles = Utility.convertMetersToMiles(theMeters: distance)
//        let hours = Double(elapsedSeconds) / 3600.0           // 3600 seconds per hour
//        var speed_miles_per_hour = 0.0 // default to 0 if hours is 0
//        if hours > 0.0 {
//            speed_miles_per_hour = miles / hours
//        }
//        return String(format: "%.1f MPH", speed_miles_per_hour)

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
    // Hours:Minutes:Seconds
    public func displayableElapsedTime() -> String {
        return Utility.getDisplayableElapsedTime(seconds: Int64(elapsedSeconds))
        
//        // Hours
//        let hours = Int32(trunc(Double(elapsedSeconds) / 3600.0)) // Number of hours
//        var remainingSeconds = elapsedSeconds % 3600
//
//        // Minutes
//        let minutes = Int32(trunc(Double(remainingSeconds) / 60)) // Number of minutes
//
//        // Seconds
//        remainingSeconds = remainingSeconds % 60
//
//        return String(format: "\(hours):%02d:%02d", minutes, remainingSeconds)
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


