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
    
//    // return the distance between the two lat/lon pairs.  If an input is invalid, then return 0
//    static func getDistanceInFeet(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
//        if lat1 > 180 || lat1 < -180 || lon1 > 180 || lon1 < -180 || lat2 > 180 || lat2 < -180 || lon2 > 180 || lon2 < -180 {
//            MyLog.debug("ERROR in getDistanceInFeet.  Lat1: \(lat1), Lon1: \(lon1), Lat2: \(lat2), Lon2: \(lon2)")
//            return 0
//        }
//                
//        let distanceInMeters = getDistanceInMeters(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2)
//        return convertMetersToFeet(theMeters: distanceInMeters)
//    }
//        
//    // return the distance between the two lat/lon pairs.  If an input is invalid, then return 0
//    static func getDistanceInMiles(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
//        if lat1 > 180 || lat1 < -180 || lon1 > 180 || lon1 < -180 || lat2 > 180 || lat2 < -180 || lon2 > 180 || lon2 < -180 {
//            MyLog.debug("ERROR in getDistanceInMiles.  Lat1: \(lat1), Lon1: \(lon1), Lat2: \(lat2), Lon2: \(lon2)")
//            return 0
//        }
//        
//        let distanceInMeters = getDistanceInMeters(lat1: lat1, lon1: lon1, lat2: lat2, lon2: lon2)
//        return convertMetersToMiles(theMeters: distanceInMeters)
//    }
        

    
    // return the distance between the two lat/lon pairs.  If an input is invalid, then return 0
    static func getDistanceInMeters(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
        if lat1 > 180 || lat1 < -180 || lon1 > 180 || lon1 < -180 || lat2 > 180 || lat2 < -180 || lon2 > 180 || lon2 < -180 {
            MyLog.debug("ERROR in getDistanceInMeters.  Lat1: \(lat1), Lon1: \(lon1), Lat2: \(lat2), Lon2: \(lon2)")
            return 0
        }
        
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)

        let distanceInMeters = loc1.distance(from: loc2)

        return distanceInMeters
    }


}


