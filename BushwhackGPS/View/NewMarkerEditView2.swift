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
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    @StateObject var mMarkerEntity: MarkerEntity // Created in the init for this view

    // Update Location button wdhx
    @State private var showingUpdateLocationConfirm = false // Flag for confirm location change dialog
    @State private var updateMarkerLocation = false // set to true if user clicks 'Update'

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
                
                
                
                
                
                
                
                
                
                
                
                
                HStack {
                    // TIME STAMP, LATITUDE, LONGITUDE wdhx
                    LatLonDisplay(theMarkerEntity: mMarkerEntity)

                    // Edit Lat Lon Location on Map
                    HStack {
                        Button("Change Location on Map") {
                            MyLog.debug("Change Location BUtton Tapped in NewMarkerEditView2")
                            showingUpdateLocationConfirm = true // Flag to cause dialog to display
                        }
                        .alert(isPresented: $showingUpdateLocationConfirm) { // wdhx
                            Alert(
                                title: Text("On the map, tap the new location for this Marker"),
                                message: Text("You can drag the map and zoom prior to tapping."),
                                primaryButton: .destructive(Text("Change Location")) {
                                    // Set Flag that tells the dialog to close
                                    EditExistingMarkerController.shared.showEditMarkerDialog = false

                                    // Set flag to update the Marker location in HandleOnDisappear() below
                                    updateMarkerLocation = true
                                    
                                    presentationMode.wrappedValue.dismiss() // Exit EditMarker dialog and go to map
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        .frame(minWidth: 0, maxWidth: 140, minHeight: 50, maxHeight: 50, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    } // HStack for Edit Map Location Button
                    .padding(SwiftUI.EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } // HStack for Lat/Lon and Edit Location buttons

                

                
                
                
                
                
                
                
                
                // PHOTO LIST
                MarkerPhotosView(theMap_VM: theMap_ViewModel, markerEntity: mMarkerEntity)
            } // ScrollView
        } // VStack - Outer Container
        .padding()
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
        
        if updateMarkerLocation == true { // wdhx added
            theMap_ViewModel.setMarkerIDForLocationUpdate(markerID: mMarkerEntity.id)
        }

    }
    
    
}


struct MarkerEditView2_Previews: PreviewProvider {
    static var previews: some View {
        NewMarkerEditView2(theMap_VM: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


