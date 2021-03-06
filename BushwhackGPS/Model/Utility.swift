//
//  Utility.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/29/22.
//


import Foundation
//import SwiftUI
import MapKit
import CoreLocation
//import StoreKit
//import Network

//
// Various Static Utility Functions for use anywhere in the app.
//

struct Utility {

    static func convertMetersToFeet(theMeters: Double) -> Double {
        let FEET_PER_METER = 3.28084
        return theMeters * FEET_PER_METER
    }

    static func convertMetersToMiles(theMeters: Double) -> Double {
        let MILES_PER_METER = 0.000621371
        return theMeters * MILES_PER_METER
    }

    
    // return the distance between the two lat/lon pairs.  If an input is invalid, then return 0
    static func getDistanceInMeters(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
        if lat1 > 180 || lat1 < -180 || lon1 > 180 || lon1 < -180 || lat2 > 180 || lat2 < -180 || lon2 > 180 || lon2 < -180 {
            return 0 // This is NOT AN ERROR - We're suposed to return 0 distance if one point is invalid
        }
        
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)

        let distanceInMeters = loc1.distance(from: loc2)

        return distanceInMeters
    }

    // Return Metric or English units depending on settings
    // For Metric
    //    - Return Meters up to 1000 meters with no digits past the decimal
    //    - Return KM up if over 1000 meters with two digits past the decial
    // For British Units
    //    - Return Feet up to 1000 feet with no digits past the decimal
    //    - Return Miles if over 1000 feet with two diits past the decimal
    static func getDisplayableDistance(useMetricUnits: Bool, meters: Double) -> String {
        // Metric
        if useMetricUnits {
            if meters < 1000 {
                return String(format: "%.0f Meters", meters)
            } else {
                // return Kilometers
                return String(format: "%.1f KM", meters/1000)
            }
        }
        // If we got this far then we're using Bristish Units
        let distanceInFeet = Utility.convertMetersToFeet(theMeters: meters)
        if distanceInFeet < 1000 {
            return String(format: "%.0f Feet", distanceInFeet)
        }
        let distanceInMiles = Utility.convertMetersToMiles(theMeters: meters)
        return String(format: "%.1f Miles", distanceInMiles)
    }

    // return the average speed in appropriate units
    // MPH or "km/h"
    // 3600 Seconds Per Hour
    static func getDisplayableSpeed(useMetricUnits: Bool, meters: Double, seconds: Int64) -> String {
        // Metric (km/h)
        if useMetricUnits {
            let km = meters/1000 // convert meters to km
            let hours = Double(seconds) / 3600.0       // 3600 seconds per hour
            var speed_km_per_hour = 0.0 // default to 0 if hours is 0
            if hours > 0.0 {
                speed_km_per_hour = km / hours
            }
            return String(format: "%.1f km/h", speed_km_per_hour)
        }

        // If we got this far then we're using Bristish Units (MPH)
        let miles = Utility.convertMetersToMiles(theMeters: meters)
        let hours = Double(seconds) / 3600.0           // 3600 seconds per hour
        var speed_miles_per_hour = 0.0 // default to 0 if hours is 0
        if hours > 0.0 {
            speed_miles_per_hour = miles / hours
        }
        return String(format: "%.1f MPH", speed_miles_per_hour)
    }
    
    
    // return elapsed time in appropriate units
    // Hours:Minutes:Seconds
    static func getDisplayableElapsedTime(seconds: Int64) -> String {
        // Hours
        let hours = Int32(trunc(Double(seconds) / 3600.0)) // Number of hours
        var remainingSeconds = seconds % 3600

        // Minutes
        let minutes = Int32(trunc(Double(remainingSeconds) / 60)) // Number of minutes

        // Seconds
        remainingSeconds = remainingSeconds % 60
        
        return String(format: "\(hours):%02d:%02d", minutes, remainingSeconds)
    }
    
    // Convert Date to String MM/DD/YYYY
    static func getShortDateTimeString(theDate: Date?) -> String {
        guard let aDate = theDate else {
            return "None"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short // .medium, .none
        return dateFormatter.string(from: aDate)
    }

    
    // ===== Apple Maps - Start Navigation to a Lat/Lon =====
    
    // NOTES: To trigger Apple Maps you must setup the URL in the plist
    //  1- Click on the Project name in the Project Navigator
    //  2- Click on 'info' in the nav-bar
    //  3- Add a line called "LSApplicationQueriesSchemes" and set it's type to Array
    //  4- Add an element to the array (which will be named 'Item 0' by default)
    //    4a - Set the element's type to String
    //    4b - Set the element's value to be 'maps'
    //
    // A more sofisticated solution is offered here with options for multiple
    // mapping apps and ability to pass in a name for the destination.  I don not
    // believe this other solution triggers the navigation, it only shows the
    // destination and you must still tap the 'Directions' button.
    // https://stackoverflow.com/questions/38250397/open-an-alert-asking-to-choose-app-to-open-map-with/60930491#60930491
    static func appleMapDirections(lat: Double, lon: Double) {
        
        // saddr = start address (or lat,lon)
        // dadder = destination address (or lat,lon)
        // Example URL:
        //   maps://?saddr=&daddr=39.906253,-104.946620
        let theURL = URL(string: "maps://?&saddr=&daddr=\(lat),\(lon)")
        // let theURL = URL(string: "maps://?q=Bananas&ll=\(lat),\(lon)")
        // let theURL = URL(string: "http://maps.apple.com/?q=Bananas&ll=\(lat),\(lon)")
        
        // Verify that the URL can be opened
        if UIApplication.shared.canOpenURL(theURL!) {
            // put [:] for options
            // put nil for the completion handler
            UIApplication.shared.open(theURL!, options: [:], completionHandler: nil)
        } else {
            print("wdh ERROR URL NOT VALID in call to appleMapDirections()")
        }
    }

    
    
}

