//
//  MapView.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/18/22.
//

import Foundation
import SwiftUI
import MapKit
import UIKit
import CoreLocation
import os


import Foundation
import SwiftUI
import MapKit
import UIKit
import CoreLocation
import os

// ======= Adding Touch Detection =======
// https://stackoverflow.com/questions/63110673/tapping-an-mkmapview-in-swiftui
// Code marked with TouchDetect
// Note the sample code passes the init a struct copy of the parent but only needs to pass a reference to the class mapView
//
// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    @State var mMapView = MKMapView() // TouchDetect - made member var instead of local var in makeUIView NOTE: MUST BE @State or duplicate instances will be created
    
    
    func isParkingSpotShownOnMap() -> Bool {
        // NOTE: There seems to be some buffer off the side of the map so sometimes it says it's shown when it isn't really
        let parkingSpotLatLon = theMap_ViewModel.getParkingSpotLocation()
        let parkingSpotMKMapPoint = MKMapPoint(parkingSpotLatLon)
        let theVisibleMKMapRect = self.mMapView.visibleMapRect
        let result = theVisibleMKMapRect.contains(parkingSpotMKMapPoint)
        return result
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        // This func is required by the UIViewRepresentable protocol
        // It returns an instance of the class MapViewCoordinator which we also made below
        // MapViewCoordinator implements the MKMapViewDelegate protocol and has a method to return
        // a renderer for the polyline layer
//        return MapViewCoordinator(mMapView, theMapVM: theMap_ViewModel) // Pass in the view model so that the delegate has access to it
        return MapViewCoordinator(self, theMapVM: theMap_ViewModel) // Pass in the view model so that the delegate has access to it
    }
    
    // Called Once when MapView is created
    func makeUIView(context: Context) -> MKMapView {

        // Part of the UIViewRepresentable protocol requirements
        mMapView.delegate = context.coordinator // Set delegate to the delegate returned by the 'makeCoordinator' function we added to this class

        // Initialize Map Settings
        // NOTE Was getting runtime error on iPhone: "Style Z is requested for an invisible rect" to fix
        //  From Xcode Menu open Product->Scheme->Edit Scheme and select 'Arguments' then add environment variable "OS_ACTIVITY_MODE" with value "disable"
//        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
//        mapView.isPitchEnabled = true
//        mapView.showsBuildings = true
        mMapView.isRotateEnabled = false // Don't let the user manually rotate the map.
        mMapView.showsUserLocation = true // Start map showing the user as a blue dot
        mMapView.showsCompass = false
        mMapView.showsScale = true  // Show distance scale when zooming
        mMapView.showsTraffic = false
        mMapView.mapType = .standard // .hybrid or .standard - Start as standard

        // Follow, center, and orient in direction of travel/heading
//        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true) // .followWithHeading, .follow, .none

        // Add the parking spot annotation to the map
        MyLog.debug("Brefore add parking spot Annotation")
        mMapView.addAnnotations([theMap_ViewModel.getParkingSpotAnnotation()])
        MyLog.debug("After add parking spot Annotation")
        theMap_ViewModel.orientMap() // zoom in on the current location and the parking location
        
        // Add the map dots to the map
        mMapView.addAnnotations(theMap_ViewModel.getDotAnnotations())
        
        return mMapView

    }
    
    
    // MARK: MapModel Changed - Update Map
    // This gets called when ever the Model changes or published variables in the ViewModel
    // Required by UIViewRepresentable protocol
    func updateUIView(_ mapView: MKMapView, context: Context) {
        MyLog.debug("MapView.updateUIView() called - MapModel changed")
        let theMapView = mapView
        var bShouldSizeAndCenter = theMap_ViewModel.isSizingAndCenteringNeeded()
        
        // Set Hybrid/Standard mode if it changed
        if (theMapView.mapType != .hybrid) && theMap_ViewModel.isHybrid {
            theMapView.mapType = .hybrid
        } else if (theMapView.mapType == .hybrid) && !theMap_ViewModel.isHybrid {
            theMapView.mapType = .standard
        }
        
        
        // UPDATE PARKING SPOT if necessary
        if theMap_ViewModel.parkingSpotMoved { // The user updated the parking spot so move the annotation
            theMap_ViewModel.parkingSpotMoved = false
            // Remove theParking Spot annotation and re-add it in case it moved and triggered this update
            // Avoid removing the User Location Annotation
            theMapView.annotations.forEach {
                if ($0 is MKParkingAnnotation) {
                    theMapView.removeAnnotation($0)
                }
            }
            
            // Now add the parking spot annotation in it's new location
            theMapView.addAnnotations([theMap_ViewModel.getParkingSpotAnnotation()])
            
            // Now orient the map for the new parking spot location
            bShouldSizeAndCenter = true // set flag that will Size and Center the map a few lines down from here
        }

        // ADD NEW DOT ANNOTATION if there is one
        if let newDotAnnotation = theMap_ViewModel.getNewAnnotation() {
            // If we got in here, then there's a new annotation to add
            MyLog.debug("Adding new dot annotation")
            theMapView.addAnnotation(newDotAnnotation)
        }
        

        // Size and Center the map Because the user hit the Orient Map Button
        if bShouldSizeAndCenter { // The use has hit the orient map button or did something requireing the map to be re-oriented
            
            theMap_ViewModel.mapHasBeenResizedAndCentered()
            
            theMap_ViewModel.startCenteringMap() // Switch to 'Centered Map Mode' to keep the map centered on the current location
            
            // Set the bounding rect to show the current location and the parking spot
            theMapView.setRegion(theMap_ViewModel.getBoundingMKCoordinateRegion(), animated: false) // If animated, this gets overwritten when heading is set
            
            // Center the map on the current location
            theMapView.setCenter(theMap_ViewModel.getLastKnownLocation(), animated: false) // If animated, this gets overwritten when heading is set

        }

        // Set the HEADING - The direction the phone is pointing, not the direction we are moving
        theMapView.camera.heading=theMap_ViewModel.getCurrentHeading() // Adjustes map direction without affecting zoom level
        
    }
    
    
    // MARK: Map Callbacks in MapViewacoordinator
    // Map Call-Backs: Delegate to handle call-backs from the MapView class.
    // This handles things like
    //   - drawing the generated poly-lines layers on the map,
    //   - returning Annotation views to render the annotation points
    //   - Draging and Selecting Annotations
    //   - Respond to map position changes etc.
    // This class is defined INSIDE the MapView Struct
    class MapViewCoordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate { // TouchDetect: added Gesture Delegate protocol
        var theMap_ViewModel: Map_ViewModel
        var parent: MapView // TouchDetect - Will need to access the parent MapView object
        var mTapGestureRecognizer = UITapGestureRecognizer() // TouchDetect - This also gets passed into the callbacks
        var mPinchGestureRecognizer = UIPinchGestureRecognizer() // TouchDetect - This also gets passed into the callbacks

        init(_ theMapView: MapView, theMapVM: Map_ViewModel) { // Pass MKMapView for TouchDetect to convert pixels to lat/lon
            theMap_ViewModel = theMapVM
            self.parent = theMapView // TouchDetect will need to reference this
            self.parent.mMapView.isUserInteractionEnabled = true
            super.init()
                        
            let thePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:))) // TouchDetect
            thePanGestureRecognizer.delegate = self // TouchDetect
            thePanGestureRecognizer.minimumNumberOfTouches = 1
            thePanGestureRecognizer.maximumNumberOfTouches = 1
//            self.mapView.addGestureRecognizer(thePanGestureRecognizer) // TouchDetect
            self.parent.mMapView.addGestureRecognizer(thePanGestureRecognizer) // TouchDetect
            
            self.mTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler)) // TouchDetect
            self.mTapGestureRecognizer.delegate = self // TouchDetect
//            self.mapView.addGestureRecognizer(mTapGestureRecognizer) // TouchDetect
            self.parent.mMapView.addGestureRecognizer(mTapGestureRecognizer) // TouchDetect

            self.mPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler)) // TouchDetect
            self.mPinchGestureRecognizer.delegate = self // TouchDetect
//            self.mapView.addGestureRecognizer(mPinchGestureRecognizer) // TouchDetect
            self.parent.mMapView.addGestureRecognizer(mPinchGestureRecognizer) // TouchDetect

        }

        // MARK: GestureRecognizer Delegate callback functions
        // GestureRecognizer Delegate function (optional)
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { // TouchDetect - Called after every gesture starts
            // This function was called because the user is messing with the map.
            theMap_ViewModel.stopCenteringMap() // Tell view model user wants to stop auto-centering map
            return true
        }

        // MARK: Custom GestureRecognizer Handler functions that I created
        @objc func tapHandler(_ sender: UITapGestureRecognizer) { // TouchDetect: detect single tap and convert to lat/lon
//            var theMapView = sender.view as MapView
            
            if sender.state != .ended {
                return // Only need to process at the end of the gesture
            }
                
            // Position on the screen, CGPoint
            let location = mTapGestureRecognizer.location(in: self.parent.mMapView)
            // postion on map, CLLocationCoordinate2D
            let coordinate = self.parent.mMapView.convert(location, toCoordinateFrom: self.parent.mMapView)
            MyLog.debug("LatLon Tapped: Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)")
//            AlertDialog.shared.Alert("wdh LatLon Tapped: Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)")
        }

        // NOTE: FOR SOME REASON the panHandler and pinchHandler call-backs don't ever get called
        @objc func panHandler(_ sender: UIPanGestureRecognizer) { // TouchDetect
            MyLog.debug("panHandler Called in MapViewCoordinator class")
        }
        @objc func pinchHandler(_ sender: UIPinchGestureRecognizer) { // TouchDetect: detect pinch
            MyLog.debug("pinchHandler Called in MapViewCoordinator class")
        }

        
        // Added to render the PolyLine Overlay to draw the route between two points
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            MyLog.debug("wdh Created PolyLine Renderer")
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        
        
        // VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
        // VVVVVVV Optional MKMapViewDelegate protocol functions that I added for demo/testing purposes VVVVV
        // VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

        // The region displayed by the map view is about to change.
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated: Bool) {
//            MyLog.debug("Called1 'func mapView(_ mapView: MKMapView, regionWillChangeAnimated: \(regionWillChangeAnimated))'")
        }
        
        // The map view's visible region changed.
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//            MyLog.debug("Called2 'func mapViewDidChangeVisibleRegion(_ mapView: MKMapView)'")
        }

        // The map view's visible region changed.
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
//            MyLog.debug("Called3 'func mapView(MKMapView, regionDidChangeAnimated: \(regionDidChangeAnimated))'")
        }
        
        // MARK: Optional - Loading the Map Data
        
        // The specified map view is about to retrieve some map data.
        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//            MyLog.debug("Called4 'func mapViewWillStartLoadingMap(_ mapView: MKMapView)'")
        }
        
        // The specified map view successfully loaded the needed map data.
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
//            MyLog.debug("wdh Finished Loading Map 'func mapViewDidFinishLoadingMap(_ mapView: MKMapView)'")
        }
        
        // The specified view was unable to load the map data.
        func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError: Error) {
//            MyLog.debug("Called6 'func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError: Error)'")
        }
        
        // The map view is about to start rendering some of its tiles.
        func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
//            MyLog.debug("Called7 'func mapViewWillStartRenderingMap(_ mapView: MKMapView)'")
        }
        
        // The map view has finished rendering all visible tiles.
        func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
//            MyLog.debug("Called7.5 func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: \(fullyRendered))'")
        }

        // MARK: Optional - Tracking the User Location
        
        // The map view will start tracking the user’s position.
        func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
//            MyLog.debug("Called8: 'func mapViewWillStartLocatingUser(_ mapView: MKMapView)'")
        }
        
        // The map view stopped tracking the user’s location.
        func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
//            MyLog.debug("Called9: 'func mapViewDidStopLocatingUser(_ mapView: MKMapView)'")
        }
        
        
        // MARK: LOCATION UPDATES CALLBACK - While Map is displayed
        //
        // The location of the user was updated.
        //    Center the map
        //    NOTE: This is only called if the map is displayed.
        //          For locaiton updates when the map is not displayed use Map_ViewModel didUpdateLocations
        func mapView(_ mapView: MKMapView, didUpdate: MKUserLocation) {
//            MyLog.debug("Called10: 'func mapView(_ mapView: MKMapView, didUpdate: MKUserLocation)'")
            
            // Center the map on the current location
            if theMap_ViewModel.shouldKeepMapCentered() { // Only do this if the user wants the map to stay centered
//                mapView.setCenter(theMap_ViewModel.getLastKnownLocation(), animated: true)
                mapView.setCenter(didUpdate.coordinate, animated: true)
            }
        }
        
        // An attempt to locate the user’s position failed.
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError: Error) {
//            MyLog.debug("Called11: 'func mapView(_ mapView: MKMapView, didFailToLocateUserWithError: Error)'")
        }
        
        // The user tracking mode changed.
        func mapView(_ mapView: MKMapView, didChange: MKUserTrackingMode, animated: Bool) {
            MyLog.debug("wdh MKUserTrackingMode: \(didChange.rawValue)")
//            MyLog.debug("Called12: 'func mapView(_ mapView: MKMapView, didChange: MKUserTrackingMode, animated: \(animated)'")
        }
        

        // Get AnnotationView
        // Return the annotation view to display for the specified annotation or
        // nil if you want to display a standard annotation view.
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            MyLog.debug("Called13: 'func mapView(_ mapView: MKMapView, viewFor: MKAnnotation) -> MKAnnotationView?'")

            // === USER LOCATION Annotation Type - Blue dot that shows your locaiton ===
            if (annotation is MKUserLocation) {
                // This is the User Location (Blue Dot) so just use the default annotation icon by returning nil
                return nil
            }
            
            // === DOT ANNOTATION Type ===
            if (annotation is MKDotAnnotation) {
                let Identifier = "Dot"
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier)

                annotationView.canShowCallout = true // Show Title and subtitle if the user taps on the annotation
                
                let DOT_SIZE = 5 // Size for Map Dot Symbol
                let DOT_COLOR = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black shows up better on hybrid background
                let DotSymbolImage = UIImage(systemName: theMap_ViewModel.getDotImageName())!.withTintColor(DOT_COLOR)
                let size = CGSize(width: DOT_SIZE, height: DOT_SIZE)

                // Create Annotation Image and return it
                annotationView.image = UIGraphicsImageRenderer(size:size).image {
                    _ in DotSymbolImage.draw(in:CGRect(origin:.zero, size:size))
                }
                
                return annotationView
            }
            
            // === PARKING SPOT Annotation type ===
            if (annotation is MKParkingAnnotation) {
                let Identifier = "ParkingSpot"
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: Identifier)

                annotationView.canShowCallout = true // Show Title and subtitle if the user taps on the annotation
                
                let PARKING_SYMBOL_SIZE = 25 // Size for Parking Symbol
                let PARKING_SYMBOL_COLOR = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black shows up better on hybrid background
                let parkingSymbolImage = UIImage(systemName: theMap_ViewModel.getParkingLocationImageName())!.withTintColor(PARKING_SYMBOL_COLOR)
                let size = CGSize(width: PARKING_SYMBOL_SIZE, height: PARKING_SYMBOL_SIZE)

                // Create Annotation Image and return it
                annotationView.image = UIGraphicsImageRenderer(size:size).image {
                    _ in parkingSymbolImage.draw(in:CGRect(origin:.zero, size:size))
                }
                
                return annotationView
            }

            return nil // We didn't handle this Annotation so return nil to use the default annotation icon.
        }
        
        
        // MARK: Optional - Managing Annotation Views

        // One or more annotation views were added to the map.
        func mapView(_ mapView: MKMapView, didAdd: [MKAnnotationView]) {
//            MyLog.debug("Called14: 'func mapView(_ mapView: MKMapView, didAdd: [MKAnnotationView])'")
        }

        // The user tapped one of the annotation view’s accessory buttons.
        func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl) {
            MyLog.debug("Called15: 'func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped: UIControl)'")
        }
        
        // Asks the delegate to provide a cluster annotation object for the specified annotations.
        func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
            MyLog.debug("THIS IS WRONG wdh Called: 'func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations: [MKAnnotation]) -> MKClusterAnnotation'")
            return MKClusterAnnotation(memberAnnotations: clusterAnnotationForMemberAnnotations) // THIS IS WRONG
        }

        
        // MARK: Optional - Dragging an Annotation View

        // The drag state of one of its annotation views changed.
        func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState) {
            MyLog.debug("Called16: 'func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange: MKAnnotationView.DragState, fromOldState: MKAnnotationView.DragState)'")
        }

        // MARK: Optional - Selecting Annotation Views
        
        // One of its annotation views was selected.
        func mapView(_ mapView: MKMapView, didSelect: MKAnnotationView) {
            let theAnnotationTitle = didSelect.annotation?.title ?? "No Title" // Default the optional value to 'No Title' in case it's nil
            MyLog.debug("Called17: ** Annotation View Selected ** '\(theAnnotationTitle!)'")
        }

        // One of its annotation views was deselected.
        func mapView(_ mapView: MKMapView, didDeselect: MKAnnotationView) {
            MyLog.debug("Called18: ** Annotation View DE-Selected **")
        }

        // Optional - Managing the Display of Overlays
        // Tells the delegate that one or more renderer objects were added to the map.
        func mapView(_ mapView: MKMapView, didAdd: [MKOverlayRenderer]) {
            MyLog.debug("Called19: 'func mapView(MKMapView, didAdd: [MKOverlayRenderer])'")
        }
            
        
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    }
    
    
    
}

