//
//  NewMarkerEditView.swift
//  BushwhackGPS
//
//  Created by William Hause on 6/10/22.
//

//import Foundation
//import SwiftUI
//import CoreLocation
//
//
//// It's safe to assume we have an Accurate Location for this view because we
//// already checked in the parrent view
//struct NewMarkerEditView_DELETE_THIS: View {
//    @ObservedObject var theMap_ViewModel: Map_ViewModel
//    
//    @State var titleText: String = ""
//    @State var bodyText: String = ""
//    @State var iconSymbolName: String = "multiply.circle" //"xmark.square.fill"
//    @State var lat: Double = 100.0
//    @State var lon: Double = -100.0
//    @State var iconColor: Color = Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0) // Red by default - Satalite and Map
//    @State var dateTimeDetailText = "" // Used to display the time with seconds
////    @State var mMarkerEntity: MarkerEntity? // non-nil if we are editing an existing marker
//            
//    // Constants
//    let LEFT_PADDING = 10.0 // Padding on the left side of various controls
//    
//    // Used when we we are creating a NEW MarkerEntity and not editing an existing one
//    init(theMap_VM: Map_ViewModel) {
//        theMap_ViewModel = theMap_VM
//    }
//    
////    // Used when editing an EXISTING MarkerEntity and not creating a new one
////    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
////        theMap_ViewModel = theMap_VM
////        mMarkerEntity = markerEntity
////    }
//    
//    var body: some View {
//        VStack {
//            
//            // Journal Entry Title and Body
//            TextDataInput(title: "Title", userInput: $titleText)
//                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 10, trailing: 0.0))
//            TextDataInputMultiLine(title: "Description", userInput: $bodyText)
//
//            // Icon Picker and Color Picker
//            HStack {
//                Text("Map Icon:")
//                Picker("mapIcon", selection: $iconSymbolName) {
//                    ForEach(theMap_ViewModel.getMarkerIconList(), id: \.self) {
//                        Label("", systemImage: $0)
//                    }
//                } //.pickerStyle(MenuPickerStyle()) //.pickerStyle(SegmentedPickerStyle()) //.pickerStyle(WheelPickerStyle())
//                Spacer()
//                
//                // Color Picker
//                VStack(alignment: .leading) {
//                    Text("Icon Color")
////                    Text("(Darker is Better)").font(.footnote)
//                }
//                ColorPicker("Icon Color", selection: $iconColor, supportsOpacity: false)
//                    .labelsHidden() // don't show the label.  Use the Text lable instead
//            } // HStack
//
//            // Date/Time Display
//            HStack {
//                Text("Time Stamp: \(dateTimeDetailText)") // Time with seconds
//                Spacer()
//            }
//            
//            
//            // LAT/LON Display
//            HStack {
//                Text("Latitude: \(lat)")
//                Spacer()
//            }
//            HStack {
//                Text("Longitude: \(lon)")
//                Spacer()
//            }
//        }
//        .padding()
////      .padding(EdgeInsets(top: 0.0, leading: LEFT_PADDING, bottom: 0, trailing: 10))
//        .navigationTitle("Journal Entry") // Title at top of page
//        .onAppear { HandleOnAppear() }
//        .onDisappear { HandleOnDisappear() }
//    }
//
//    
//    // This will be called when ever the view apears
//    // Calling this from .onAppear in the Body of the view.
//    func HandleOnAppear() {
//        Haptic.shared.impact(style: .heavy)
//    
//        // We are creating a new Marker Entity so initialze the values to defaults
//        lat = theMap_ViewModel.getCurrentLocation()?.coordinate.latitude ?? 100.0
//        lon = theMap_ViewModel.getCurrentLocation()?.coordinate.longitude ?? -100.0
//
//        // Set default Title
//        // Use creation date as the default title
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        dateFormatter.timeStyle = .short // .medium
//        titleText = dateFormatter.string(from: Date())
//        dateFormatter.timeStyle = .medium
//        dateTimeDetailText = dateFormatter.string(from: Date())
//    }
//    
//    func HandleOnDisappear() {
//        Haptic.shared.impact(style: .heavy)
//
//        if titleText.isEmpty {
//            titleText = "Unnamed"
//        }
//        
//        theMap_ViewModel.addNewMarker(lat: self.lat, lon: self.lon, title: titleText, body: bodyText, iconName: iconSymbolName, color: iconColor)
//    }
//    
//    
//}
//
//
//struct MarkerEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMarkerEditView_DELETE_THIS(theMap_VM: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
//
//
