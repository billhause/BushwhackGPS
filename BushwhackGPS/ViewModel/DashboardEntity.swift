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
            theDashboardEntity.distance = 0 // meters
//            theDashboardEntity.pointCount = 0
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

        // save changes
        save()
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
    }

    
    // return the average speed in appropriate units
    // MPH or "km/h"
    // 3600 Seconds Per Hour
    public func displayableAvgSpeed() -> String {
        return Utility.getDisplayableSpeed(useMetricUnits: AppSettingsEntity.getAppSettingsEntity().metricUnits,
                                           meters: distance,
                                           seconds: Int64(elapsedSeconds))
    }

//    public func displayableSpeed() -> String {
//        return Utility.getDisplayableSpeed(useMetricUnits: AppSettingsEntity.getAppSettingsEntity().metricUnits,
//                                           meters: 1,
//                                           seconds: 1)
//    }

    
    
    
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
    }
    
    public func displayableTripFuelCost_DELETE_THIS_NOW() -> String {
        let gasPrice = AppSettingsEntity.getAppSettingsEntity().gasPrice
        let mpg = AppSettingsEntity.getAppSettingsEntity().mpg
        var adjustedDistance = distance // distance in meters
        if AppSettingsEntity.getAppSettingsEntity().metricUnits {
            adjustedDistance = adjustedDistance / 1000 // Convert meters to km
        } else {
            adjustedDistance = Utility.convertMetersToMiles(theMeters: distance)
        }
        let totalCost = gasPrice / mpg * adjustedDistance
        var moneySymbol = "" // No money symbol if not US or GB
        if NSLocale.current.regionCode == "GB" { // Great Britian
            moneySymbol = "£"
        } else if NSLocale.current.regionCode == "US" {
            moneySymbol = "$"
        }
        let dollarString = String(format: "%.2f", totalCost)
        return "\(moneySymbol)\(dollarString)"
    }
    
//    Next add Fuel Cost to TripDetailsView
    
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


