//
//  MarkerDetailsView.swift
//  BushwhackGPS
//
//  Created by William Hause on 5/31/22.
//

import SwiftUI
import CoreData
import CoreLocation

struct MarkerDetailsView: View {
    
    // NOTE: We can't initialize the @FetchRequest predicate because the MarkerEntity is passed
    // in to the init().  Therefore we need to construct the FetchRequest in the init()
    @FetchRequest var imageEntities: FetchedResults<ImageEntity>
    
    @ObservedObject var theMap_ViewModel: Map_ViewModel

    @State var mMarkerEntity: MarkerEntity // non-nil if we are editing an existing marker

        
    // Used when editing an EXISTING MarkerEntity and not creating a new one
    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
        theMap_ViewModel = theMap_VM
        
        // NOTE: PropertyWrapper Structs must be accessed using the underbar '_' version of the struct
        // Put an '_' in front of the variable names to access them directly.
        _mMarkerEntity = State(initialValue: markerEntity) // Variable 'self.mMarkerEntity' used before being initialized
        
        // LOAD THE IMAGES
        // Must Setup the Predecate for the Fetch Request in the init()
        //    See Stanford Lesson 12 at 1:02:20
        //    https://www.youtube.com/watch?v=yOhyOpXvaec
        let request = NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
        request.predicate = NSPredicate(format: "marker = %@", markerEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)] // Put newest at top
        _imageEntities = FetchRequest(fetchRequest: request) // Use '_' version to access wrapped variable
    }

    
    // TODO: Factor out the common views from ExistingMarkerView, MarkerDetailsView and NewMarkerView
    
    var body: some View {
        
// wdhx        Next Step: Flesh out the MarkerDetailsView based on the ExistingMarkerEditView
        
        VStack(alignment: .leading) {
            HStack {
                Spacer()
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
            }

        } // VStack
        .navigationTitle("Journal Entry") // Title at top of page

        
        
        Spacer()
        Text("Marker Entity: \(mMarkerEntity.wrappedTitle)")
        Spacer()
        Text("Future Marker Details View - displayed by selecting a marker from a list.")
        Spacer()
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
    
    func handleMapDirectionsButton() {
        let lat = mMarkerEntity.lat
        let lon = mMarkerEntity.lon
        Utility.appleMapDirections(lat: lat, lon: lon)
        MyLog.debug("MarkerDetailsView: Opening Apple Map Directions for lat:\(lat), lon:\(lon)")
    }


}

struct MarkerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MarkerDetailsView(theMap_VM: Map_ViewModel(), markerEntity: MarkerEntity())
    }
}
