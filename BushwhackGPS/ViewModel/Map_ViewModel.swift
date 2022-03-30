//
//  BWViewModel.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/18/22.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import StoreKit
import Network

// MARK: Constants
let THRESHOLD_DISTANCE = 10.0 // Minimum Number of meteres that you must move to get a new dot added to the map
let THRESHOLD_TIME_PERIOD = 10.0 // // Minimum Number of seconds that must pass to get a new dot added to the map

class Map_ViewModel: NSObject, ObservableObject, CLLocationManagerDelegate  {
    // This class
    //   1 - provides data to the view in a way the view can easily consume it
    //   2 - provides 'Intent' functions for the view to change the data
    
    // MARK: Member Vars
    @Published private var theMapModel: Map_Model = Map_Model()
    @Published public var parkingSpotMoved = false // Signal when the parking spot moves so the map knows to move the parking icon
    @Published public var dotFilterIsDirty = false // signal when the map must update all points because the dot filter changed
    
    private var mLocationManager: CLLocationManager?
    private var mLastDotTimeStamp: Double = 0.0 // The Last Dot's timestamp since jan 1 1970 that the last dot was created

    // Flags to communicate with the mapView since the MapView never knows what data model change triggere an update
    private var mStillNeedToOrientMap = true // Set to true when the map needs to be oriented
    private var mNewDotAnnotationWaiting = false // Set to true if there is a new dot annotation waiting to be added to the map
    private var mNewMarkerAnnotationWaiting = false // Set to true if there is a new Marker annotation waiting to be added to the map

    private var mMarkerIconList: [String] = []
    private var mMarkerIconNames = [
        "doc.richtext",
        "xmark.square.fill",
        "multiply.circle",
        "house.fill",
        "house",
        "heart.fill",
        "star.fill",
        "parkingsign.circle",
        "car.fill",
        "car.circle",
        "bolt.car",
        "fuelpump",
        "fork.knife.circle",
        "cup.and.saucer.fill",
        "bed.double",
        "airplane.circle",
        "bus",
        "tram",
        "ferry.fill",
        "bicycle",
        "graduationcap.fill",
        "figure.walk",
        "figure.stand",
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "peacesign",
        "hand.raised.fill",
        "hand.thumbsup",
        "hand.thumbsdown",
        "burst",
        "burn",
        "globe",
        "moon.fill",
        "sun.max.fill",
        "moon.zzz.fill",
        "snowflake",
        "flame.fill",
        "exclamationmark.triangle.fill",
        "exclamationmark.octagon",
        "dollarsign.square.fill",
        "wifi.circle",
        "wifi",
        "music.note", 
        "circle",
        "triangle",
        "square",
        "flag.fill",
        "camera.fill",
        "phone.fill",
        "cart.circle",
        "cart.fill",
        "stethoscope.circle",
        "cross.case",
        "cross.circle",
        "building",
        "face.smiling",
        "photo",
        "binoculars.fill",
        "questionmark.circle.fill",
        "exclamationmark.circle.fill",
        "paperplane.fill",
        "hand.raised.square.on.square",
        "bell.fill",
        "creditcard",
        "wrench",
        "case",
        "iphone.homebutton",
        "dot.radiowaves.left.and.right",
        "pawprint",
        "pawprint.circle",
        "sportscourt",
        "photo.on.rectangle.angled",
        "scope",
        "trash",
        "a.circle.fill",
        "b.circle.fill",
        "c.circle.fill",
        "d.circle.fill",
        "e.circle.fill",
        "f.circle.fill",
        "g.circle.fill",
        "h.circle.fill",
        "i.circle.fill",
        "j.circle.fill",
        "k.circle.fill",
        "l.circle.fill",
        "m.circle.fill",
        "n.circle.fill",
        "o.circle.fill",
        "p.circle.fill",
        "q.circle.fill",
        "r.circle.fill",
        "s.circle.fill",
        "t.circle.fill",
        "u.circle.fill",
        "v.circle.fill",
        "w.circle.fill",
        "x.circle.fill",
        "y.circle.fill",
        "z.circle.fill",
        "0.circle.fill",
        "1.circle.fill",
        "2.circle.fill",
        "3.circle.fill",
        "4.circle.fill",
        "5.circle.fill",
        "6.circle.fill",
        "7.circle.fill",
        "8.circle.fill",
        "9.circle.fill",
        "10.circle.fill",
        "11.circle.fill",
        "12.circle.fill",
        "13.circle.fill",
        "14.circle.fill",
        "15.circle.fill",
        "16.circle.fill",
        "17.circle.fill",
        "18.circle.fill",
        "19.circle.fill",
        "20.circle.fill"
    ]


    
    // MARK: Flag Variables
    var isHybrid: Bool { // Expose this so the View can modify it indirectily through the ViewModel
        get {
            return theMapModel.isHybrid
        }
        set(newValue) {
            theMapModel.isHybrid = newValue
        }
    }

//    // Flag to signal to the map that the user wants the map re-centered and oriented in his direction
//    private var orientMapFlag: Bool {
//        get {
//            return theMapModel.orientMapFlag
//        }
//        set(orientFlag) {
//            theMapModel.orientMapFlag = orientFlag
//        }
//    }

    @objc func appMovedToBackground() {
        MyLog.debug("appMovedToBackground() called in Map_ViewModel")
        mLocationManager?.stopUpdatingHeading() // Must reduce background processing to avoid app suspension
        // mLocationManager?.distanceFilter = DISTANCE_FILTER_VALUE // Meters - Won't get a new point unless you move at least 10 meters
    }
    
    @objc func appMovingToForeground() {
        MyLog.debug("appMovingToForeground() called in Map_ViewModel")
        mLocationManager?.startUpdatingHeading() // Will call the delegates didUpdateHeading function when heading changes
        // mLocationManager?.distanceFilter = kCLDistanceFilterNone
    }
    
    // MARK: Init Functions
    override init() {

        // Initialize the LocationManager - https://stackoverflow.com/questions/60356182/how-to-invoke-a-method-in-a-view-in-swiftui
        // Good Article on Location Manager Settings and fields etc: https://itnext.io/swift-ios-cllocationmanager-all-in-one-b786ffd37e4a
        
        UIApplication.shared.isIdleTimerDisabled = true // to help prevent suspension after being put in the background - does not work 100%
        
        mLocationManager = CLLocationManager()
        super.init() // Call the NSObject init - Must be after member vars are initialized and before 'self' is referenced

        if mLocationManager == nil {
            MyLog.debug("ERROR mLocationManager is nil in Map_ViewModel.init()")
        }
        
        // Apps that want to receive location updates when suspended must include the UIBackgroundModes key (with the location value) in their app’s Info.plist

        // To Receive Backgroun Location Updates...
        // NOTE: MUST CHECK THE XCODE App Setting box for 'Location Updates' in the 'Background Modes' section under the 'Signing and Capabilities' tab

        // a comment said 'you're not handling the location key properly https://developer.apple.com/forums/thread/69152
        // There is an indication that requestLocation stops the location service once the request has been fulfilled https://developer.apple.com/library/content/documentation/Performance/Conceptual/EnergyGuide-iOS/LocationBestPractices.html
        // Try setting the CLLocationManager ActivityType to fitness vs automotiveNavigation.  This is used by iOS to pause locaiton updates in the background state to conserve power
        
        // mLocationManager?.requestWhenInUseAuthorization()
        mLocationManager?.requestAlwaysAuthorization() // Request permission even when the app is not in use
        mLocationManager?.startUpdatingLocation() // Will call the delegate's didUpdateLocations function when locaiton changes
        mLocationManager?.delegate = self
        mLocationManager?.allowsBackgroundLocationUpdates = true //MUST CHECK THE XCODE App Setting box for 'Location Updates' in the 'Background Modes' section under the 'Signing and Capabilities' tab

        mLocationManager?.desiredAccuracy = kCLLocationAccuracyBest
        mLocationManager?.distanceFilter = THRESHOLD_DISTANCE // Meters - Won't get a new point unless you move at least 10 meters
        mLocationManager?.pausesLocationUpdatesAutomatically = false // Avoid pausing when in background or suspended
        // mLocationManager?.activityType = .automotiveNavigation // will disable when indoors
        mLocationManager?.activityType = .otherNavigation // non-automotive vehicle
        // mLocationManager?.activityType = .fitness // will disable when indoors
        // mLocationManager?.startMonitoringSignificantLocationChanges() // only updates every 5 minutes for 500 meter or more change
        mLocationManager?.startUpdatingHeading() // Will call the delegates didUpdateHeading function when heading changes
        
        
        // Register to receive notification when the app goes into the background or moves back to foreground
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(appMovingToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
        buildMarkerIconList() // Build the array of valid icons in mMarkerIconList and filter out any invalid names
    }

    // Return a list of Journal Marker string names to pick from
    // This should only be called once to initialize the icon list.
    private func buildMarkerIconList() {
        for currentIconName in mMarkerIconNames {
            if UIImage(systemName: currentIconName) != nil {
                mMarkerIconList.append(currentIconName)
            } else {
                // Didn't find the image
                MyLog.debug("ERROR: Unable to find image for \(currentIconName) in buildMarkerIconList()")
            }
        }
    }

    
    // Return a list of Journal Marker string names to pick from
    func getMarkerIconList() -> [String] {
        return mMarkerIconList
    }

    
    // View should call this to inform the ViewModel that the map no longer needs to be oriented
    func mapHasBeenResizedAndCentered() {
        mStillNeedToOrientMap = false
    }
    // View should call this to find out if the map needs to be oriented
    func isSizingAndCenteringNeeded() -> Bool {
        return mStillNeedToOrientMap
    }
    
    // Return the current location or nil if we dont' have one
    func getCurrentLocation() -> CLLocation? {
        if let currentLocation = mLocationManager?.location {
            return currentLocation
        }
        return nil // we couldn't find a location so return nil
    }
    
    private var mLastKnownLocation: CLLocationCoordinate2D?
    // This will ALWAYS return a location even if it's not current
    func getLastKnownLocation() -> CLLocationCoordinate2D {
        // Get current location.  IF none, then use the parking spot location as the current location
        if mLastKnownLocation != nil {
            return mLastKnownLocation!
        }
        return getParkingSpotLocation()
    }

    
    // vvv MARKER ID DELETION vvv
    // Trigger a MarkerAnnotation Deletion from the map
    private var mMarkerIDForDeletion: Int64 = 0
    func setMarkerIDForDeletion(markerID: Int64) {
        mMarkerIDForDeletion = markerID
    }
    // Set back to 0 after being called
    func getMarkerIDForDeletion() ->Int64 {
        let temp = mMarkerIDForDeletion
        mMarkerIDForDeletion = 0
        return temp
    }
    // ^^^ MARKER ID DELETION ^^^
    // ^^^^^^^^^^^^^^^^^^^^^^^^^
    
    
    // vvv MARKER ID REFRESH vvv
    // Trigger a MarkerAnnotation Refresh on the map
    // Marker Icon's don't refresh on their own.  You must remove and re-add the MarkerAnnotationView to get it to refresh
    // This has been confirmed by personal google research
    // That is why we have these functions and flags
    private var mMarkerIDForRefresh: Int64 = 0
    func setMarkerIDForRefresh(markerID: Int64) {
        mMarkerIDForRefresh = markerID
    }
    // Set back to 0 after being called
    func getMarkerIDForRefresh() ->Int64 {
        let temp = mMarkerIDForRefresh
        mMarkerIDForRefresh = 0
        return temp
    }
    // ^^^ MARKER ID REFRESH ^^^
    // ^^^^^^^^^^^^^^^^^^^^^^^^^
    
    func updateExistingMarker(theMarker: MarkerEntity, lat: Double, lon: Double, title: String, body: String, iconName: String, color: Color) {
        theMarker.title = title
        theMarker.desc = body
        theMarker.iconName = iconName
        
        // Extract the RGB color values and save them in the Entity
        var rgbRed: CGFloat = 0
        var rgbBlue: CGFloat = 0
        var rgbGreen: CGFloat = 0
        var rgbAlpha: CGFloat = 0
        let myUIColor = UIColor(color)
        myUIColor.getRed(&rgbRed, green: &rgbGreen, blue: &rgbBlue, alpha: &rgbAlpha)
        theMarker.colorRed = rgbRed
        theMarker.colorBlue = rgbBlue
        theMarker.colorGreen = rgbGreen
        theMarker.colorAlpha = rgbAlpha // should always be 1.0 for display on map
        
        MarkerEntity.saveAll()
        
        setMarkerIDForRefresh(markerID: theMarker.id) // Must tell the map to remove and re-add the MarkerAnnotationView to refresh the icon
        
    }

    
    // Add a new marker to the current location using specified values
    func addNewMarker(lat: Double, lon: Double, title: String, body: String, iconName: String, color: Color) { 
        
        // Create a new marker and save it
        let newMarkerEntity = MarkerEntity.createMarkerEntity(lat: lat, lon: lon)
        updateExistingMarker(theMarker: newMarkerEntity, lat: lat, lon: lon, title: title, body: body, iconName: iconName, color: color)
        
        // Update model with the waiting MarkerAnnotation
        theMapModel.waitingMKMarkerAnnotation = MarkerAnnotation(theMarkerEntity: newMarkerEntity)
        mNewMarkerAnnotationWaiting = true // This will be set to false after the marker is requested
    }

    
    // Location Accuracy Status Values
    // Used to determine if we can add a new Marker to the map
    enum LocationAccuracyStatus {
        case NoLocation
        case InaccurateLocation
        case GoodLocation
    }
    
    // Rerturn the status of our location accuracy NoLocation, InaccurateLocation or GoodLocation
    func getLocationStatus() -> LocationAccuracyStatus {
        let REQUIRED_LOCATION_ACCURACY = 60.0 // minimum location accuracy in meters required to create a log entry.
        guard let currentLocation = getCurrentLocation() else {
            return LocationAccuracyStatus.NoLocation
        }
        if currentLocation.horizontalAccuracy < REQUIRED_LOCATION_ACCURACY {
            return LocationAccuracyStatus.GoodLocation
        }
        return LocationAccuracyStatus.InaccurateLocation
    }
    
    
    
    // Find the distance between the parking spot and the current location.
    // Make the map width/height be double that distance minus some buffer percentage
    // make sure the center stays in the center after subtracting the buffer
    func getBoundingMKCoordinateRegion() -> MKCoordinateRegion {
        let parkingLocation = getParkingSpotLocation()
        let lastKnownLocation = getLastKnownLocation()

        // Convert from lat/lon to points so we can do distance math
        let parkLoc = MKMapPoint(parkingLocation)
        let centLoc = MKMapPoint(lastKnownLocation)

        // Pathagorean Theorem to find distance
        let dx = Double(parkLoc.x-centLoc.x)
        let dy = Double(parkLoc.y-centLoc.y)
        var distance = pow((pow(dx,2) + pow(dy,2)), 0.5) // square root of A Squared plus B Squard
        distance = distance * 1.1 // Add buffer around the map so the parking location stays on the map
        
        // The Left and Right sides will be the center +/- the distance between the points
        let left = centLoc.y - distance
        let bottom = centLoc.y - distance
        let width = distance * 2
        let height = distance * 2
        
        let theMKMapRect = MKMapRect.init(x: left, y: bottom, width: width, height: height) // Lower Left origin
        let theMKCoordinateRegion = MKCoordinateRegion(theMKMapRect)
        return theMKCoordinateRegion
    }

    //
    // DOT ANNOTATION COLOR AND SIZE
    //
    let DEFAULT_MAP_DOT_SIZE: Double = 6.0
    let DEFAULT_MAP_DOT_COLOR: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    typealias DotSizeAndUIColor = (size: CGFloat, theUIColor: UIColor)
    func getDotSizeAndUIColor(theMKDotAnnotation: MKDotAnnotation) -> DotSizeAndUIColor {
//        MyLog.debug("getDotSizeAndUIColor Called")
        let dotDate = theMKDotAnnotation.mDotEntity.timestamp
        guard let theTripEntity = TripEntity.getTripEntityForDate(theDate: dotDate!) else {
            // Return default dot size and color
            return (size: DEFAULT_MAP_DOT_SIZE, theUIColor: DEFAULT_MAP_DOT_COLOR)
        }
        
        return (size: theTripEntity.dotSize, theUIColor: theTripEntity.dotUIColor)
    }

    // return the distance between the two lat/lon pairs.  If an imput is invalid, then return 0
    //
    func getDistanceInMeters(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double {
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

    

    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getDotImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "circle.fill") != nil { return "circle.fill" }
        return "circle" // default that is always there on all devices
    }

    
    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getParkingLocationImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "parkingsign.circle") != nil { return "parkingsign.circle" }
        if UIImage(systemName: "parkingsign") != nil { return "parkingsign" }
        if UIImage(systemName: "car") != nil { return "car" }
        return "triangle" // default that is always there on all devices
    }

    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getOrientMapImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "dot.circle.viewfinder") != nil { return "dot.circle.viewfinder" }
        if UIImage(systemName: "dot.arrowtriangles.up.right.down.left.circle") != nil { return "dot.arrowtriangles.up.right.down.left.circle" }
        return "triangle" // default that is always there on all devices
    }

    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getMapLayerImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "square.3.stack.3d") != nil { return "square.3.stack.3d" }
        if UIImage(systemName: "square.stack.3d.up") != nil { return "square.stack.3d.up" }
        if UIImage(systemName: "map") != nil { return "map" }
        return "triangle" // default that is always there on all devices
    }

    
    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getTripButtonImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "map") != nil { return "map" }
        return "triangle" // default that is always there on all devices
    }

    // Convert Date to String MM/DD/YYYY
    func getShortDateString(theDate: Date?) -> String {
        guard let aDate = theDate else {
            return "None"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
//        dateFormatter.timeStyle = .short // .medium
        return dateFormatter.string(from: aDate)
    }


    
    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getCompassImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "safari") != nil { return "safari" }
        if UIImage(systemName: "location.north") != nil { return "location.north" }
        if UIImage(systemName: "dot.arrowtriangles.up.right.down.left.circle") != nil { return "dot.arrowtriangles.up.right.down.left.circle" }
        return "triangle" // default that is always there on all devices
    }

    // Sometimes the device will not have the first choice symbol so check first
    // Return a default that is always present
    func getAddJournalEntryImageName() -> String {
        // Check symbols in order of preference
        if UIImage(systemName: "square.and.pencil") != nil { return "square.and.pencil" }
        if UIImage(systemName: "pencil.circle") != nil { return "pencil.circle" }
        if UIImage(systemName: "plus.circle") != nil { return "plus.circle" }
        if UIImage(systemName: "plus.square") != nil { return "plus.square" }
        if UIImage(systemName: "plus.app") != nil { return "plus.app" }
        return "triangle" // default that is always there on all devices
    }

    
    // Check if the specified location is within THRESHOLD distancce meters of any of the
    // previous CLUSTER_TAIL_SIZE point.  Return true if it is, false otherwise
    let CLUSTER_TAIL_SIZE = 15 // How many points at the end of the array should be checked
    func pointIsClustered(theLocation: CLLocation) -> Bool {
        // Look at the last X points and if the specified point is within the threshold distance, then return true
        let dotEntityArray = getFilteredDotEntites()
        let count = dotEntityArray.count
        
        // Would crash if trying to check 0 or fewer points at the end of the array
        if CLUSTER_TAIL_SIZE <= 0 { return false }
        
        // Must have more points in the array than the number of points we're going to check
        var clusterTailSize = CLUSTER_TAIL_SIZE
        if count <= CLUSTER_TAIL_SIZE {
            clusterTailSize = count
        }

        for index in stride(from: count-1, through: count-clusterTailSize, by: -1) {
            let oldLocation = CLLocation(latitude: dotEntityArray[index].lat, longitude: dotEntityArray[index].lon)
            if theLocation.distance(from: oldLocation) < THRESHOLD_DISTANCE * 0.9  { // Allow a 10% buffer
//                MyLog.debug("** POINT REJECTED Becaue it's too close to another recent point")
                return true // there's already a recent point too close to the target point
            }
        }
        return false
    }
    
    
    // MARK: LOCATION UPDATE

    // REQUIRED - Called EVERY TIME the location data is updated
    // The MOST RECENT location is the last one in the array
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations: [CLLocation]) {
//        MyLog.debug("--- locationManager Update Location wdh ---")

        let currentLocation = didUpdateLocations.last!
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        let speed = currentLocation.speed
        let course = currentLocation.course

        // Update last known location
        mLastKnownLocation = currentLocation.coordinate
        
        // === DASHBOARD ===
        DashboardEntity.getDashboardEntity().updateDashboardEntity(newLat: currentLocation.coordinate.latitude,
                                                                   newLon: currentLocation.coordinate.longitude)
        
        // === ADD MAP DOT ===
        // Since we can't add the dot annotation directly to the MapView, we must add it to
        // the MapModel which will trigger a map update where
        // the annotation will be added to the map as an AnnotationView
        let deltaTime = NSDate().timeIntervalSince1970 - mLastDotTimeStamp // mCurrentWayPoint.timeStamp
        if(deltaTime > THRESHOLD_TIME_PERIOD) { // Wait to add the next point
            // Dont' add the point if it's already in a cluster of recent points E.g. just walking around the house
            if !pointIsClustered(theLocation: currentLocation) {
                let newDotEntity = DotEntity.createDotEntity(lat: lat, lon: lon, speed: speed, course: course) // save to DB
                let dotAnnotation = MKDotAnnotation(theDotEntity: newDotEntity)
//                let dotAnnotation = MKDotAnnotation(coordinate: currentLocation.coordinate, id: newDotEntity.id)
                theMapModel.waitingMKDotAnnotation = dotAnnotation // Update the MapModel with the new annotation to be added to the map
                
                // The Map_ViewModel must keep track if there is a new annotation to add to
                // the map since the MapView doesn't know what data change triggered the update
                mNewDotAnnotationWaiting = true
                mLastDotTimeStamp = Date().timeIntervalSince1970
            }
        }
        
        // === PARKING SPOT ===  Update the parking spot location if it's been moved
        if theMapModel.updateParkingSpotFlag == true {
            // Update the parking spot location and set the flag back to false
            theMapModel.updateParkingSpotFlag = false
            ParkingSpotEntity.getParkingSpotEntity().updateLocation(lat: lat, lon: lon, andSave: true)
            
            // Temporarily set the distaneFilter to none until the parking spot is updated
            mLocationManager?.distanceFilter = THRESHOLD_DISTANCE
            
            // Now that the parking spot has been updated, let the map know to move the marker
            parkingSpotMoved = true
        }
        
    }

    
    // Will return nil if newMKDotAnnotation is nil or if the annotation has already been returned once.
    func getNewDotAnnotation() -> MKDotAnnotation? {
        if mNewDotAnnotationWaiting {
            mNewDotAnnotationWaiting = false
            return theMapModel.waitingMKDotAnnotation
        }
        return nil // No new dot annotation is waiting
    }
    
    
    // Return nil if there is not a new MarkerAnnotation waiting to be added
    // Otherwise return the MarkerAnnotation to be added
    func getNewMarkerAnnotation() -> MarkerAnnotation? {
        if mNewMarkerAnnotationWaiting {
            mNewMarkerAnnotationWaiting = false
            return theMapModel.waitingMKMarkerAnnotation
        }
        return nil // No new Marker annotation are waiting
    }
    
    
    func getDistanceInFeet(p1: CLLocationCoordinate2D, p2: CLLocationCoordinate2D) -> Int {
        // Calculate Distance
        
        let source = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
        let destination = CLLocation(latitude: p2.latitude, longitude: p2.longitude)
        
        let distanceInMeters = source.distance(from: destination)
        let distanceInFeet = Int(distanceInMeters * 3.28084) // Convert to Feet
        return distanceInFeet
    }
    
    // REQUIRED
    // This must be implemented or you'll get a runtime error when requesting a map location update
    // Tells the delegate that the location manager was unable to retrieve a location value.
    func locationManager(_ locationManager: CLLocationManager, didFailWithError: Error) {
        MyLog.debug("wdh Due to looking for location before user approved Allow Once ERROR Map_ViewModel.locationManager(didFailWithError) Error: \(didFailWithError.localizedDescription)")
    }
    

    
    // Heading - Tells the delegate that the location manager received updated heading information.
    // Note: Must have previously called mLocationManager?.startUpdatingHeading() for this to be called
    func locationManager(_ locationManager: CLLocationManager, didUpdateHeading: CLHeading) {
//        theMapModel.currentHeading = didUpdateHeading.magneticHeading
        theMapModel.currentHeading = didUpdateHeading.trueHeading // Should use this, not magnetic north
    }

    // Tells the delegate when the app creates the location manager and when the authorization status changes.
    func locationManagerDidChangeAuthorization(_ locationManager: CLLocationManager) {
        MyLog.debug("locationManagerDidChangeAuthorization called")
    }


    // Tells the delegate that updates will no longer be deferred.
    func locationManager(_ locationManager: CLLocationManager, didFinishDeferredUpdatesWithError: Error?) {
        MyLog.debug("** wdh UNEXPECTED location manager updates will no longer be deferred")
    }

    // Tells the delegate that location updates were paused.
    func locationManagerDidPauseLocationUpdates(_ locationManager: CLLocationManager) {
        // We don't want to pause in the background so if this is ever turned off, turn it back on
        mLocationManager?.startUpdatingLocation()
        MyLog.debug("*** ERROR - INVESTIGATE THIS wdh UNEXPECTED Location Manager Paused so I restarted it")
    }


    // Tells the delegate that the delivery of location updates has resumed.
    func locationManagerDidResumeLocationUpdates(_ locationManager: CLLocationManager) {
        MyLog.debug("*** ERROR - INVESTIGATE THIS wdh UNEXPECTED Location Manager Did Resume Location Updates")
    }


    // Asks the delegate whether the heading calibration alert should be displayed.
    //func locationManagerShouldDisplayHeadingCalibration(_ locationManager: CLLocationManager) -> Bool {}

    // NOTE: There are OTHER CALLBACKs not listed above
    
    
    // MARK: Intent Functions
    
    // Tell the map to delete and reload all MapDot Annotations wdhx
    func requestMapDotAnnotationRefresh() {
        MyLog.debug("****** requestMapDotAnnotationRefresh() called")
        dotFilterIsDirty = true // signal that the map should refresh all of its map dots
    }
    

    // return true if the map should refresh all of the MapDot Annotations
    func isMapDotRefreshNeeded() -> Bool {
        if dotFilterIsDirty {
            dotFilterIsDirty = false // set back to false
            return true // Yes the map should refresh all the map dots
        }
        return false
    }
    
//    // Allow nil to be passed in as date to indicate no date
//    func updateFilterStartDate(_ newDate: Date?) {
//        AppSettingsEntity.getAppSettingsEntity().updateFilterStartDate(newDate)
//        dotFilterIsDirty = true // Allow map to check what changed when doing its update
//    }
//    // Allow nil to be passed in as date to indicate no date
//    func updateFilterEndDate(_ newDate: Date?) {
//        AppSettingsEntity.getAppSettingsEntity().updateFilterEndDate(newDate)
//        dotFilterIsDirty = true // Allow map to check what changed when doing its update
//    }
//    func hasFilterStartDate() -> Bool {
//        if AppSettingsEntity.getAppSettingsEntity().filterStartDate == nil {
//            return false
//        }
//        return true
//    }
//    func hasFilterEndDate() -> Bool {
//        if AppSettingsEntity.getAppSettingsEntity().filterEndDate == nil {
//            return false
//        }
//        return true
//    }
    
    func orientMap() {
        theMapModel.orientMapFlag = true // Change Data Model to Trigger map update
        mStillNeedToOrientMap = true // True until the map tells us it's been oriented using the mapHasBeenOriented() intent func
//        AlertMessage.shared.Alert("Test Alert: Called from ViewModel orientMap()")
    }

    func updateParkingSpot() {
        // Set the Flag to tell the callback to upate the parking spot location SEE: locationManager(didUpdateLocations:) in this same class
        theMapModel.updateParkingSpotFlag = true

        // Temporarily set the distaneFilter to none until the parking spot is updated
        mLocationManager?.distanceFilter = kCLDistanceFilterNone
        
        // Tell the location manager to upate the location and call the locationManager(didUpdateLocations:) function above.
        mLocationManager?.requestLocation()
    }
    
        
    func requestReview() {
        if AppSettingsEntity.getAppSettingsEntity().usageCount > AppSettingsEntity.REVIEW_THRESHOLD {
        // NOTE: If not connected to Internet, then requestReview will lock the interface
            let reachability = try? Reachability() // Return nil if throws an error
            if reachability?.connection == .wifi {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } else if reachability?.connection == .cellular {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
    
    func stopCenteringMap() {
        // Call this when the user is manipulating the map by hand to stop the map from recentering
        theMapModel.followMode = false
    }
    func turnOnFollowMode() {
        // Call this if the user wants the map to stay centered on the current location
        theMapModel.followMode = true
    }
        
    func shouldKeepMapCentered() -> Bool {
        // This tells the caller if the map should be centered or not
        return theMapModel.followMode
    }
    
    
    // MARK: Getters

    func getCurrentHeading() -> Double {
        return theMapModel.currentHeading
    }
    
    func getParkingSpotLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: ParkingSpotEntity.getParkingSpotEntity().lat, longitude: ParkingSpotEntity.getParkingSpotEntity().lon)
    }
    
    func getParkingSpotAnnotation() -> MKAnnotation {
        return MKParkingAnnotation(coordinate: getParkingSpotLocation())
    }
        
    // Get the list of DotEntities that pass the date TripEntity filters
    // Ignore TripEntities that have showTripDots == false
    // if the endTime is nil, then the end time is open ended
    private func getFilteredDotEntites() -> [DotEntity] {
        let allTripEntities = TripEntity.getAllTripEntities_NewestToOldest()
        let allDotEntities = DotEntity.getAllDotEntities()
        
        // Create a new dot array with the dots that don't pass the filter removed
        let filteredDotEntities = allDotEntities.filter {
            // Return TRUE if the $0 DotEntity should be displayed on the map, FALSE otherwise
            
            if $0.timestamp == nil {return false} // This should never happen dots are assigned a date when created

            // Check each ACTIVE TripEntity and if the dot should be displyed return true
            for theTripEntity in allTripEntities {
                if theTripEntity.showTripDots {
                    if ($0.timestamp! > theTripEntity.startTime!) {
                        if theTripEntity.endTime == nil { return true } // The dot will be displayed by this TripDetailsView
                        if $0.timestamp! < theTripEntity.endTime! { return true }
                    }
                }
            }
            
            return false // the dot's date is will not be shown by any TripEntity
        }
        return filteredDotEntities
    }
    
    // Return an array of all MarkerAnnotation objects ready to be added to the map
    func getMarkerAnnotations() -> [MarkerAnnotation] {
        let allMarkerEntities = MarkerEntity.getAllMarkerEntities()
        // Build array of MarkerAnnotations
        var markerAnnotations: [MarkerAnnotation] = []
        for markerEntity in allMarkerEntities {
            let newMarkerAnnotation = MarkerAnnotation(theMarkerEntity: markerEntity)
            markerAnnotations.append(newMarkerAnnotation)
        }
        return markerAnnotations
    }
    
    
    // Return an array of DotAnnotations ready to be added to the map
    // This func will filter out any dots that don't fall in the date filter range
    func getDotAnnotations() -> [MKDotAnnotation] { 
        // Create Annotations for ech of the dots that passed the filter.
        var dotAnnotations: [MKDotAnnotation] = []
        
        let filteredDotEntities = getFilteredDotEntites()
        for dotEntity in filteredDotEntities {
            let newMKDotAnnotation = MKDotAnnotation(theDotEntity: dotEntity)
//            let newMKDotAnnotation = MKDotAnnotation(coordinate: CLLocationCoordinate2D(latitude: dotEntity.lat, longitude: dotEntity.lon), id: dotEntity.id)
            dotAnnotations.append(newMKDotAnnotation)
        }
        return dotAnnotations
    }
}


// MARK: Annotation Types

class MKParkingAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String? = "Parking Spot"
    var subtitle: String? = ""
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

//class MKDotAnnotation2: NSObject, MKAnnotation {
//    var coordinate: CLLocationCoordinate2D
//    var title: String? = "Dot Annotation"
//    var subtitle: String? = ""
//    var id: Int64
////    var timestamp: Date
//    init(coordinate: CLLocationCoordinate2D, id: Int64) {
//        self.coordinate = coordinate
//        self.id = id
//    }
//}

// NOTE: MKAnnotation REQUIRES a coordinate, title and description.
// We provide those as computed properties calculated from the DotEntity
// This class stores a refernce to its associated DotEntity object.
class MKDotAnnotation: NSObject, MKAnnotation {
    let mDotEntity: DotEntity // reference to the DotEntity
    init(theDotEntity: DotEntity) {
        mDotEntity = theDotEntity
    }
    var coordinate: CLLocationCoordinate2D { // computed property
        get {
            return CLLocationCoordinate2D(latitude: mDotEntity.lat, longitude: mDotEntity.lon)
        }
    }
    var title: String? { // computed property
        get {
            // Use creation date as the default title
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .medium // .short .medium .long
            let timeStamp = dateFormatter.string(from: mDotEntity.timestamp!)
            let speedMPH = NSString(format:"%.1f", mDotEntity.speed*2.24) // m/s to mph
            return "\(timeStamp), \(speedMPH) MPH"
        }
    }
    
    var subtitle: String? { //computed Property
        get {
            // 5 digits past decimal is accurate to 1.1 meters at equator
            let latString = NSString(format:"%.5f", mDotEntity.lat) // 8 digits past dicimal max
            let lonString = NSString(format:"%.5f", mDotEntity.lon)
            let headingString = NSString(format:"%.0f°", mDotEntity.course)
            let theSubTitle = "lat:\(latString), long:\(lonString), heading:\(headingString)"
            return theSubTitle
        }
    }

    var id: Int64 {
        get {
            return mDotEntity.id
        }
    }
    
}



// NOTE: MKAnnotation REQUIRES a coordinate, title and description.
// We provide those as computed properties calculated from the MarkerEntity
// This class stores a refernce to its associated MarkerEntity object.
class MarkerAnnotation: NSObject, MKAnnotation {

    var mMarkerEntity: MarkerEntity // reference to the MarkerEntity
    init(theMarkerEntity: MarkerEntity) {
        mMarkerEntity = theMarkerEntity
    }

    
    var coordinate: CLLocationCoordinate2D { // computed property
        get {
            return CLLocationCoordinate2D(latitude: mMarkerEntity.lat, longitude: mMarkerEntity.lon)
        }
    }
    var title: String? { // computed property
        get {
            return mMarkerEntity.title
        }
    }
    
    var subtitle: String? { //computed Property
        get {
            return mMarkerEntity.desc
        }
    }
    
    var symbolName: String {
        get {
            return mMarkerEntity.iconName!
        }
    }

    var id: Int64 {
        get {
            return mMarkerEntity.id
        }
    }
    
    var color: UIColor {
        return UIColor(red: mMarkerEntity.colorRed, green: mMarkerEntity.colorGreen, blue: mMarkerEntity.colorBlue, alpha: mMarkerEntity.colorAlpha)
    }
}
