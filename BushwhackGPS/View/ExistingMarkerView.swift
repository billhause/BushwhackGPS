//
//  ExistingMarkerView.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/5/22.
//

import Foundation
import SwiftUI
import CoreLocation
import CoreData


// It's safe to assume we have an Accurate Location for this view because we
// already checked in the parrent view
struct ExistingMarkerEditView: View {
    
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    
    //@State var mMarkerEntity: MarkerEntity // non-nil if we are editing an existing marker
    @ObservedObject var mMarkerEntity: MarkerEntity // non-nil if we are editing an existing marker

    // Delete Journal Entry
    @State private var showingDeleteJournalConfirm = false // Flag for Confirm Dialog
    @State private var deleteThisMarker = false // Set to true if user clicks delete
    
    // Update Location button - Similar logic to Delete Journal Entry code wdhx
    @State private var showingUpdateLocationConfirm = false // Flag for confirm location change dialog
    @State private var updateMarkerLocation = false // Set to true if user clicks 'Update'
    
    @State var dateTimeDetailText = "" // Used to display the time with seconds
            
    // Constants
    let LEFT_PADDING = 10.0 // Padding on the left side of various controls
    
    // Used when editing an EXISTING MarkerEntity and not creating a new one
    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
        theMap_ViewModel = theMap_VM
        mMarkerEntity = markerEntity
        
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {

                // vvv Share Button vvv
                Button(action: handleShareButton) {
                    let exportImageName = theMap_ViewModel.getExportImageName()
                    Label("Send a Copy", systemImage: exportImageName)
                        .foregroundColor(.accentColor)
                } // .font(.system(size: 25.0))
                    .labelStyle(VerticalLabelStyle())
                // ^^^ Share Button ^^^
                
                Spacer()
                
                // vvv Apple Map Navigation Button vvv
                Button(action: handleMapDirectionsButton) {
                    let mapDirectionsImageName = theMap_ViewModel.getNavigationImageName()
                    Label("Get Directions", systemImage: mapDirectionsImageName)
                        .foregroundColor(.accentColor)
                } // .font(.system(size: 25.0))
                    .labelStyle(VerticalLabelStyle())
                // ^^^ Apple Map Navigation Button ^^^
                
                Spacer()
                
                Button("Done") {
                    // wdhx - Set this same flag when Edit Lat Lon is clicked to exit the dialog
                    EditExistingMarkerController.shared.showEditMarkerDialog = false // Flag that tells the dialog to close
                }
            }
            
            HStack {
                Text("Journal Entry")
                    .font(.title)
                Spacer()
            }
            .padding(.top)

            ScrollView {
                
                TitleIconColorDescription( theMap_ViewModel: theMap_ViewModel,
                                           title: $mMarkerEntity.wrappedTitle,
                                           iconName: $mMarkerEntity.wrappedIconName,
                                           iconColor: $mMarkerEntity.wrappedColor,
                                           description: $mMarkerEntity.wrappedDesc)

                // Delete Journal Entry
                HStack {
                    Spacer()
                    Button("Delete Journal Entry") { 
                        showingDeleteJournalConfirm = true // Flag to cause dialog to display
                    }
                    .alert(isPresented: $showingDeleteJournalConfirm) { // wdhx
                        Alert(
                            title: Text("Are you sure you want to delete this journal entry?"),
                            message: Text("This cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                // Set Flag that tells the dialog to close
                                EditExistingMarkerController.shared.showEditMarkerDialog = false
                                
                                // Set flag to delete the Marker in HandleOnDisappear() below
                                deleteThisMarker = true
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .center)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Spacer()
                }
                .padding(SwiftUI.EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

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
//                        Spacer()
                        Button("Edit Location on Map") {
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
//                                    deleteThisMarker = true
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        .frame(minWidth: 0, maxWidth: 120, minHeight: 50, maxHeight: 50, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
//                        Spacer()
                    } // HStack for Edit Map Location Button
                    .padding(SwiftUI.EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                } // HStack for Lat/Lon and Edit Location buttons
                
                // PHOTO LIST VIEW
                MarkerPhotosView(theMap_VM: theMap_ViewModel, markerEntity: mMarkerEntity)
            
            } // Scroll View

        } // VStack
        .padding()
        .navigationTitle("Journal Marker") // Title at top of page
        .onAppear { handleOnAppear() }
        .onDisappear { handleOnDisappear() }
    }

    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func handleOnAppear() {
        
        Haptic.shared.impact(style: .heavy)
        MyLog.debug("handleOnAppear() Existing Marker Entity called")
        
        theMap_ViewModel.requestReview() // Request a review after X runs have occured
        

        // Check if the marker entity has been removed from it's context and if so, don't open the window
        // This could happen when the users deletes the marker and
        // then it's still showing on the map and they tap the Info
        // icon in the pop-up bubble
        if mMarkerEntity.managedObjectContext != nil {
            // All Is Well
            MyLog.debug("GOOD - The Marker Entity is NOT nil")
        } else {
            MyLog.debug(("MarkerEntity IS nil"))
            
            // Immediately Hide the ExistingMarkerDialog view
            EditExistingMarkerController.shared.showEditMarkerDialog = false // hide the dialog
            return // We can't show the edit view with a nil Marker Entity
        }

        // Use creation date as the default title
        dateTimeDetailText = Utility.getShortDateTimeString(theDate: mMarkerEntity.wrappedTimeStamp)
        
        theMap_ViewModel.setMarkerIDForRefresh(markerID: mMarkerEntity.id)
        MarkerEntity.saveAll()
    }
    
    func handleOnDisappear() {
        Haptic.shared.impact(style: .heavy)
        
        // Delete Marker If Necessary
        if deleteThisMarker == false {
            if mMarkerEntity.wrappedTitle == "" { 
                mMarkerEntity.wrappedTitle = "Unnamed" // Must have a name or the pop-up won't work
            }

            theMap_ViewModel.setMarkerIDForRefresh(markerID: mMarkerEntity.id)
            MarkerEntity.saveAll()
        } else {
            theMap_ViewModel.setMarkerIDForDeletion(markerID: mMarkerEntity.id)
        }
        
        // Update Marker Location if Necessary wdhx
        if deleteThisMarker {return} // Don't bother if we're deleting the marker
        if updateMarkerLocation == true {
            theMap_ViewModel.setMarkerIDForLocationUpdate(markerID: mMarkerEntity.id)
        }

        
        
    }
    
    func handleMapDirectionsButton() {
        let lat = mMarkerEntity.lat
        let lon = mMarkerEntity.lon
        Utility.appleMapDirections(lat: lat, lon: lon)
        MyLog.debug("ExistingMarkerEditView: Opening Apple Map Directions for lat:\(lat), lon:\(lon)")
    }
    
    func handleShareButton() {
        MyLog.debug("handleShareButton() called")

        // Got to get the ViewController that should present the child ViewController
        // https://stackoverflow.com/questions/32696615/warning-attempt-to-present-on-which-is-already-presenting-null
        // https://stackoverflow.com/questions/56533564/showing-uiactivityviewcontroller-in-swiftui
        //        Check out the 61 approved solution for SwiftUI calling UIActivityViewController AND the 15 approved addition to it.
        //        Also Check this out to get the Top ViewController 360 up votes
        // https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller/26667122#26667122
                                                        
        DispatchQueue.main.async { // Not sure it this helps or hurts
            theMap_ViewModel.exportJournalMarker(markerEntity: mMarkerEntity)
        }

    }
}




struct ExistingMarkerEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExistingMarkerEditView(theMap_VM: Map_ViewModel(), markerEntity: MarkerEntity.createMarkerEntity(lat: 100,lon: 100)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).previewInterfaceOrientation(.portraitUpsideDown)
    }
}



class EditExistingMarkerController: ObservableObject {
    static var shared = EditExistingMarkerController()
    
    // To show an alert, set theMessage and set the showAlert bool to true
    var theMarkerEntity: MarkerEntity?
    @Published var showEditMarkerDialog = false // Must be published to trigger the dialog to show
    
    func MarkerDialog(_ markerEntity: MarkerEntity) {
        theMarkerEntity = markerEntity
        showEditMarkerDialog = true
    }
    
}
