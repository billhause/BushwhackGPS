//
//  Map_Model.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/18/22.
//


import Foundation
import CoreLocation

// MARK: Model
struct Map_Model {
    var currentHeading = 0.0
    var isHybrid = false       // Track if the hybrid map or the standard map is displayed
    var keepMapCentered = true // Will set to false if the user starts manipulating the map manually

    var orientMapFlag = false  // This flag signals the map to orient it'self maybe it should be in the ViewModel instead
    var updateParkingSpotFlag = false // Set flag to true if the parking spot should be updated
        
//    var currentLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(40.0), longitude: CLLocationDegrees(-105.0))
    // The parking location is stored in CoreData ParkingSpotEntity
}