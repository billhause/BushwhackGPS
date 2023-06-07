//
//  NewMarkerEditView2.swift
//  BushwhackGPS
//
//  Created by William Hause on 6/10/22.
//

import Foundation
import SwiftUI
import CoreLocation


// It's safe to assume we have an Accurate Location for this view because we
// already checked in the parrent view
struct NewMarkerEditView2: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    @StateObject var mMarkerEntity: MarkerEntity // Created in the init for this view
    
    var dateTimeDetailText: String // Used to display the time with seconds
            
    // Constants
    let LEFT_PADDING = 10.0 // Padding on the left side of various controls
    
    // Used when we we are creating a NEW MarkerEntity and not editing an existing one
    init(theMap_VM: Map_ViewModel) {
        theMap_ViewModel = theMap_VM

        // note PropertyWrapper Objects must be accessed using the underbar '_' version of the object
        // Put an '_' in front of the variable names to access them directly
        // Must use the StateObject() to initialize in the init method
        _mMarkerEntity = StateObject(wrappedValue: MarkerEntity.createMarkerEntity(lat: 100, lon: 100))
        
        
        // Set default Title
        // Use creation date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short // .medium
        dateFormatter.timeStyle = .medium
        dateTimeDetailText = dateFormatter.string(from: Date())

    }
    
    
    var body: some View {
        VStack {
            ScrollView {
                TitleIconColorDescription( theMap_ViewModel: theMap_ViewModel,
                                           title: $mMarkerEntity.wrappedTitle,
                                           iconName: $mMarkerEntity.wrappedIconName,
                                           iconColor: $mMarkerEntity.wrappedColor,
                                           description: $mMarkerEntity.wrappedDesc)
                
                // Date/Time Display
                HStack {
                    Text("Time Stamp: \(Utility.getShortDateTimeString(theDate: mMarkerEntity.wrappedTimeStamp))") // Time with seconds
                    Spacer()
                }

                // TIME STAMP, LATITUDE, LONGITUDE
                LatLonDisplay(theMarkerEntity: mMarkerEntity)

                // PHOTO LIST
                MarkerPhotosView(theMap_VM: theMap_ViewModel, markerEntity: mMarkerEntity)
            } // ScrollView
        } // VStack - Outer Container
        .padding()
//      .padding(EdgeInsets(top: 0.0, leading: LEFT_PADDING, bottom: 0, trailing: 10))
        .navigationTitle("Journal Entry") // Title at top of page
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
    }

    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        Haptic.shared.impact(style: .heavy)
    
        // We are creating a new Marker Entity so initialze the values to defaults
        let lat = theMap_ViewModel.getCurrentLocation()?.coordinate.latitude ?? 100.0
        let lon = theMap_ViewModel.getCurrentLocation()?.coordinate.longitude ?? -100.0
        mMarkerEntity.lat = lat
        mMarkerEntity.lon = lon
        mMarkerEntity.wrappedIconName = theMap_ViewModel.getDefaultMarkerImageName()
        
    }
    
    func HandleOnDisappear() {
        Haptic.shared.impact(style: .heavy)

        if mMarkerEntity.wrappedTitle.isEmpty {
            mMarkerEntity.wrappedTitle = "Unnamed"
        }
        
        theMap_ViewModel.addNewMarkerEntity(theMarkerEntity: mMarkerEntity)
//        theMap_ViewModel.addNewMarker(lat: self.lat, lon: self.lon, title: titleText, body: bodyText, iconName: iconSymbolName, color: iconColor)
    }
    
    
}


struct MarkerEditView2_Previews: PreviewProvider {
    static var previews: some View {
        NewMarkerEditView2(theMap_VM: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


