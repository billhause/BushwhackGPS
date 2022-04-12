//
//  NewMarkerView.swift
//  BushwhackGPS
//
//  Created by William Hause on 2/24/22.
//

import Foundation
import SwiftUI
import CoreLocation


struct NewMarkerView: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
        
    init(theMap_VM: Map_ViewModel) {
//        MyLog.debug("*** NewMarkerView init() called")
        theMap_ViewModel = theMap_VM
    }
    var body: some View {
        VStack {
            if theMap_ViewModel.getLocationStatus() == .NoLocation {
                Text("No Location Available - We can't create a new Journel Entry without a location.")
                    .padding()
                Text("If you have not enabled 'Location Access' for this app, open Settings and scroll down to this app.  Then enable 'Location Access' and try again.")
                    .padding()
            } else
            if theMap_ViewModel.getLocationStatus() == .InaccurateLocation {
                Text("Insufficient Location Accuracy to create a reliable Journal Marker location")
                    .padding()
                Text("Wait for better Location Accuracy and try again")
                    .padding()
            } else {
                NewMarkerEditView(theMap_VM: theMap_ViewModel)
            }
        }
    }
}

// It's safe to assume we have an Accurate Location for this view because we
// already checked in the parrent view
struct NewMarkerEditView: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    
    @State var titleText: String = ""
    @State var bodyText: String = ""
    @State var iconSymbolName: String = "multiply.circle" //"xmark.square.fill"
    @State var lat: Double = 100.0
    @State var lon: Double = -100.0
    @State var iconColor: Color = Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0) // Red by default - Satalite and Map
    @State var dateTimeDetailText = "" // Used to display the time with seconds
//    @State var mMarkerEntity: MarkerEntity? // non-nil if we are editing an existing marker
            
    // Constants
    let LEFT_PADDING = 10.0 // Padding on the left side of various controls
    
    // Used when we we are creating a NEW MarkerEntity and not editing an existing one
    init(theMap_VM: Map_ViewModel) {
        theMap_ViewModel = theMap_VM
    }
    
//    // Used when editing an EXISTING MarkerEntity and not creating a new one
//    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
//        theMap_ViewModel = theMap_VM
//        mMarkerEntity = markerEntity
//    }
    
    var body: some View {
        VStack {
            
            // Journal Entry Title and Body
            TextDataInput(title: "Title", userInput: $titleText)
                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 10, trailing: 0.0))
            TextDataInputMultiLine(title: "Description", userInput: $bodyText)

            // Icon Picker and Color Picker
            HStack {
                Text("Map Icon:")
                Picker("mapIcon", selection: $iconSymbolName) {
                    ForEach(theMap_ViewModel.getMarkerIconList(), id: \.self) {
                        Label("", systemImage: $0)
                    }
                } //.pickerStyle(MenuPickerStyle()) //.pickerStyle(SegmentedPickerStyle()) //.pickerStyle(WheelPickerStyle())
                Spacer()
                
                // Color Picker
                VStack(alignment: .leading) {
                    Text("Icon Color")
//                    Text("(Darker is Better)").font(.footnote)
                }
                ColorPicker("Icon Color", selection: $iconColor, supportsOpacity: false)
                    .labelsHidden() // don't show the label.  Use the Text lable instead
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
        .navigationTitle("Journal Entry") // Title at top of page
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
    }

    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        Haptic.shared.impact(style: .heavy)
    
        // We are creating a new Marker Entity so initialze the values to defaults
        lat = theMap_ViewModel.getCurrentLocation()?.coordinate.latitude ?? 100.0
        lon = theMap_ViewModel.getCurrentLocation()?.coordinate.longitude ?? -100.0

        // Set default Title
        // Use creation date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short // .medium
        titleText = dateFormatter.string(from: Date())
        dateFormatter.timeStyle = .medium
        dateTimeDetailText = dateFormatter.string(from: Date())
    }
    
    func HandleOnDisappear() {
        Haptic.shared.impact(style: .heavy)
        theMap_ViewModel.addNewMarker(lat: self.lat, lon: self.lon, title: titleText, body: bodyText, iconName: iconSymbolName, color: iconColor)
    }
    
    
}


struct MarkerEditView_Previews: PreviewProvider {
    static var previews: some View {
        NewMarkerEditView(theMap_VM: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}



// Generic data input with a label and field to enter data
// Nice Looking Animated Input Controls with Animation for label
// https://www.youtube.com/watch?v=Sg0rfYL3utI
struct PrettyTextField: View {
    var title: String
    @Binding var userInput: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .zIndex(2)
                .foregroundColor(userInput.isEmpty ? Color(.placeholderText) : .accentColor)
                .offset(y: userInput.isEmpty ? 0 : -30) // move up if text is not empty
                .scaleEffect(userInput.isEmpty ? 1.0 : 0.8, anchor: .leading) // 80% size after moving up
            TextField("", text: $userInput)
                .zIndex(1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.top, 15)
        .animation(.default)
    }
}

// Generic data input with a label and field to enter data
// Nice Looking Animated Input Controls with Animation for label
// https://www.youtube.com/watch?v=Sg0rfYL3utI
struct TextDataInput: View {
    var title: String
    @Binding var userInput: String
    
    var body: some View {
        HStack {
            Text("\(title):")
        TextField("\(title)", text: $userInput)                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}


struct TextDataInputMultiLine: View {
    var theTitle: String
    @Binding var theUserInput: String
    var theIdealHeight: CGFloat
    
    init(title: String, userInput: Binding<String>, idealHeight: CGFloat = 100) {
        theTitle = title
        _theUserInput = userInput // The compiler wraps the var name with an underscore
        theIdealHeight = idealHeight
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            Text(theTitle)
                .font(.body)
                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -5, trailing: 0.0))
            TextEditor(text: $theUserInput)
                .frame(minWidth: 100, idealWidth: 10000, maxWidth: 10000, minHeight: 70, idealHeight: theIdealHeight, maxHeight: 10000, alignment: .leading) // Settings to avoid shrinking edit box to 0 when keyboard appears
                .multilineTextAlignment(.leading)
                .overlay( // Round the edit boundry frame
                         RoundedRectangle(cornerRadius: 5)
                           .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}

