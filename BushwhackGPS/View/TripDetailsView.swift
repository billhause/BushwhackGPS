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
    @ObservedObject var mTripEntity: TripEntity // SHOULD THIS BE @StateObject??? No TripEntity is a class passed in from outside

    var earliestStartDate: Date // will be initialized to the earliest possible start date for the trip in init()
    
    init(theTripEntity: TripEntity) {
        mTripEntity = theTripEntity
        
        // Set the earliest Start Date for a trip to be used to initialize the Date Picker
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        earliestStartDate = formatter.date(from: "2022/02/01")! // Feb 1, 2022 is earliest possible trip start date
        //        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //        earliestStartDate = formatter.date(from: "2022/02/03 00:05")!
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Dot Size Picker
            HStack {
                Text("Trip Details").font(.title2)
                Spacer()
                Spacer()
                Picker("DisplayHide", selection: $mTripEntity.showTripDots) {
                    Text("Show on Map").tag(true)
                    Text("Hide").tag(false)
                }
                .pickerStyle(.segmented)
            }

            TextDataInput(title: "Trip Name", userInput: $mTripEntity.wrappedTitle)
            TextDataInputMultiLine(title: "Description", userInput: $mTripEntity.wrappedDesc)
            
            // Dot Size Picker
            HStack {
                Text("Map Dot Size: ")
                Picker("Dot Size", selection: $mTripEntity.dotSize) {
                    Text("Small").tag(1.0)
                    Text("Medium").tag(2.0)
                    Text("Large").tag(3.0)
                }
                .pickerStyle(.segmented)
            }
            Text("Map Dot Size Value: \(mTripEntity.dotSize)")
            
            // Dot Color Picker
            HStack {
                Text("Map Dot Color: ")
                ColorPicker("Dot Color", selection: $mTripEntity.dotColor, supportsOpacity: false)
                    .labelsHidden()
            }

            // Trip Start Date
            DatePicker("Trip Start Time",
                       selection: $mTripEntity.wrappedStartTime,
                       in: earliestStartDate...Date(), // Between earliest possible start date and now
                       displayedComponents: [.date, .hourAndMinute])

            // Trip End Date
            DatePicker("Trip End Time",
                       selection: $mTripEntity.wrappedEndTime,
                       in: mTripEntity.wrappedStartTime..., // must be sometime after the start time
                       displayedComponents: [.date, .hourAndMinute])

Figure out why the second date picker to be displayed does not respond to touches in the simulator but works on the iPhone
            
        }
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
        .padding()
        
    }
    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
//        MyLog.debug("HandleOnAppear() Called for TripDetailsView")
    }
    
    func HandleOnDisappear() {
//        MyLog.debug("HandleOnDisappear() Called for TripDetailsView")
        mTripEntity.save()
    }

}

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailsView(theTripEntity: TripEntity())
    }
}
