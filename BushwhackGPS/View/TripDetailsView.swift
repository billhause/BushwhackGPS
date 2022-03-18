//
//  TripDetailsView.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/17/22.
//

import SwiftUI
import CoreData

struct TripDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var theTripEntity: TripEntity
    
    @State var dotColor: Color
    
    init(theTripEntity: TripEntity) {
        self.theTripEntity = theTripEntity
        dotColor = Color(.sRGB,
                          red: theTripEntity.dotColorRed,
                          green: theTripEntity.dotColorGreen,
                          blue: theTripEntity.dotColorBlue)
    }
    
//    newTrip.id = ID_GeneratorEntity.getNextID()
//    newTrip.uuid = UUID()
//    newTrip.title
//    newTrip.desc = ""
//    newTrip.dotColorRed = 0.0
//    newTrip.dotColorBlue = 0.0
//    newTrip.dotColorGreen = 1.0
//    newTrip.dotColorAlpha = 1.0
//    newTrip.dotSize = 3.0
//    newTrip.startTime = Date()
//    newTrip.endTime = nil

    
    var body: some View {
        VStack(alignment: .leading) {
//            Text("Trip Details").font(.title)
            Text("Trip Details").font(.title2)
//            Text("Trip Details").font(.title3)
//            Text("Trip Details").font(.callout)
//            Text("Trip Details").font(.subheadline)
//            Text("Trip Details").font(.headline)
            TextDataInput(title: "Name", userInput: $theTripEntity.wrappedTitle)
            TextDataInputMultiLine(title: "Description", userInput: $theTripEntity.wrappedDesc)
            
            // Dot Size Picker
            HStack {
                Text("Dot Size: ")
                Picker("Dot Size", selection: $theTripEntity.dotSize) {
                    Text("Small").tag(1.0)
                    Text("Medium").tag(2.0)
                    Text("Large").tag(3.0)
                }
                .pickerStyle(.segmented)
            }
            Text("Value: \(theTripEntity.dotSize)")
            
            // Dot Color Picker
            HStack {
                ColorPicker("Dot Color", selection: $dotColor, supportsOpacity: false)
                Spacer()
                Text("Coconuts")
CONTINUE HERE - Figure out how to get the color dot to appear next to the 'Dot Color' label
            }

            // Date Picker Start Date
            
            // Date Picker End Date
        }
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
        .padding()
        
    }
    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        MyLog.debug("HandleOnAppear() Called for TripDetailsView")
    }
    
    func HandleOnDisappear() {
        MyLog.debug("HandleOnDisappear() Called for TripDetailsView")
    }

}

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailsView(theTripEntity: TripEntity())
    }
}
