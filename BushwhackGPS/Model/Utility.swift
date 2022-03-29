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


// Various Utility Functions for use anywhere in the app.
struct Utility {
    // return the distance between the two lat/lon pairs.  If an imput is invalid, then return 0
    //
    static func getDistanceInMeters(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
        if lat1 > 180 || lat1 < -180 || lon1 > 180 || lon1 < -180 || lat2 > 180 || lat2 < -180 || lon2 > 180 || lon2 < -180 {
            MyLog.debug("ERROR in getDistanceInMeters.  Lat1: \(lat1), Lon1: \(lon1), Lat2: \(lat2), Lon2: \(lon2)")
            return 0
        }
        
        let loc1 = CLLocationCoordinate2D(latitude: lat1, longitude: lon1)
        let loc2 = CLLocationCoordinate2D(latitude: lat2, longitude: lon2)

        // Convert from lat/lon to points so we can do distance math
        let point1 = MKMapPoint(loc1)
        let point2 = MKMapPoint(loc2)

        // Pathagorean Theorem to find distance
        let dx = Double(point1.x-point2.x)
        let dy = Double(point1.y-point2.y)
        let distance = pow((pow(dx,2) + pow(dy,2)), 0.5) // square root of A Squared plus B Squard
        return distance
    }


}


