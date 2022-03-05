//
//  ExistingMarkerView.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/5/22.
//

import Foundation
import SwiftUI
import CoreLocation


// It's safe to assume we have an Accurate Location for this view because we
// already checked in the parrent view
struct ExistingMarkerEditView: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    
    @State var titleText: String = ""
    @State var bodyText: String = ""
    @State var iconSymbolName: String = "multiply.circle" //"xmark.square.fill"
    @State var lat: Double = 100.0
    @State var lon: Double = -100.0
    @State var iconColor: Color = Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0) // Red by default - Satalite and Map
    @State var dateTimeDetailText = "" // Used to display the time with seconds
    @State var mMarkerEntity: MarkerEntity // non-nil if we are editing an existing marker
            
    // Constants
    let LEFT_PADDING = 10.0 // Padding on the left side of various controls
    
//    // Used when we we are creating a NEW MarkerEntity and not editing an existing one
//    init(theMap_VM: Map_ViewModel) {
//        theMap_ViewModel = theMap_VM
//    }
    
    // Used when editing an EXISTING MarkerEntity and not creating a new one
    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
        theMap_ViewModel = theMap_VM
        mMarkerEntity = markerEntity
    }
    
    var body: some View {
        VStack {
            
            // Journal Entry Title and Body
            TextDataInput(title: "Title", userInput: $titleText)
                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 10, trailing: 0.0))
            TextDataInputMultiLine(title: "Journal Entry", userInput: $bodyText)
            
            // Icon Picker and Color Picker
            HStack {
                Text("Map Icon:")
                Picker("mapIcon", selection: $iconSymbolName) {
                    ForEach(theMap_ViewModel.getMarkerIconList(), id: \.self) {
                        Label("", systemImage: $0)
                    }
                } //.pickerStyle(MenuPickerStyle()) //.pickerStyle(SegmentedPickerStyle()) //.pickerStyle(WheelPickerStyle())

                // Color Picker
                ColorPicker("Icon Color (Darker is better)", selection: $iconColor, supportsOpacity: false)
                    .padding()
            } // HStack

            // Date/Time Display
            HStack {
                Text("Time Stamp: \(dateTimeDetailText)") // Time with seconds
                Spacer()
            }
            
            
            // LAT/LON Display
            HStack {
                Text("Latitude: \(lat)")
                Spacer()
            }
            HStack {
                Text("Longitude: \(lon)")
                Spacer()
            }
        }
        .padding()
//      .padding(EdgeInsets(top: 0.0, leading: LEFT_PADDING, bottom: 0, trailing: 10))
        .navigationTitle("New Journal Marker") // Title at top of page
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
    }

    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        Haptic.shared.impact(style: .heavy)
        MyLog.debug("HandleOnAppear() Existing Marker Entity called")
        
        // We are editing an existing Marker Entity
        // Initialize the fields based on the MarkerEntity we are editig
        titleText = mMarkerEntity.title!
        bodyText = mMarkerEntity.desc!
        iconSymbolName = mMarkerEntity.iconName!
        lat = mMarkerEntity.lat
        lon = mMarkerEntity.lon
        iconColor = Color(.sRGB, red: mMarkerEntity.colorRed, green: mMarkerEntity.colorGreen, blue: mMarkerEntity.colorBlue)
        
        // Use creation date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        dateTimeDetailText = dateFormatter.string(from: mMarkerEntity.timestamp!)
    }
    
    func HandleOnDisappear() {
        Haptic.shared.impact(style: .heavy)
        MyLog.debug("** HandleOnDisappear() Selected Icon is \(iconSymbolName)")
        
        // TODO: Move this call into MarkerEntity instead of having it in the Map_ViewModel
        theMap_ViewModel.updateExistingMarker(theMarker: mMarkerEntity, lat: self.lat, lon: self.lon, title: titleText, body: bodyText, iconName: iconSymbolName, color: iconColor)


        
    }
    
    
}


struct ExistingMarkerEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExistingMarkerEditView(theMap_VM: Map_ViewModel(), markerEntity: MarkerEntity.createMarkerEntity(lat: 100,lon: 100)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}



// Example Call:
//   EditMarkerController.shared.MarkerDialog(theMarkerEntityToEdit)
//
// NOTE: The ContentView must have a view that is setup to show an EditMarkerController dialog like this:
//   @StateObject var theMarkerEditDialog = EditMarkerController.shared
// AND a View (like a Spacer) with a .sheet property
//if #available(iOS 15.0, *) {
//    Spacer()
//    .sheet(isPresented:$theMarkerEditDialog.showEditMarkerDialog) {
//        MarkerEditView(theMap_VM: theMap_ViewModel, markerEntity: theMarkerEditDialog.theMarkerEntity!)
//    }
//} else {
//    // Fallback on earlier versions
//    Spacer()
//}


class EditExistingMarkerController: ObservableObject {
    static var shared = EditExistingMarkerController()
    
    // To show an alert, set theMessage and set the showAlert bool to true
    var theMarkerEntity: MarkerEntity?
    var showEditMarkerDialog = false
    
    func MarkerDialog(_ markerEntity: MarkerEntity) {
        theMarkerEntity = markerEntity
        showEditMarkerDialog = true
    }
    
}
