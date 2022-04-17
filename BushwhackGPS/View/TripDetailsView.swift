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
    private var theMap_ViewModel: Map_ViewModel
    
    init(theTripEntity: TripEntity, mapViewModel: Map_ViewModel) {
        mTripEntity = theTripEntity
        theMap_ViewModel = mapViewModel
                
        // Set the earliest Start Date for a trip to be used to initialize the Date Picker
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        earliestStartDate = formatter.date(from: "2022/02/01")! // Feb 1, 2022 is earliest possible trip start date
        //        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        //        earliestStartDate = formatter.date(from: "2022/02/03 00:05")!
    }
    
    
    var body: some View {
        VStack { // Outer VStack needed for preview
            Text("Trip Details").font(.title2)
            ScrollView(showsIndicators: false) {

                TextDataInput(title: "Trip Name", userInput: $mTripEntity.wrappedTitle)
                TextDataInputMultiLine(title: "Description", userInput: $mTripEntity.wrappedDesc, idealHeight: 125)

                VStack(alignment: .leading) {
                    // Dot Size Picker
                    HStack {
                        Text("Map Dot Size: ")
                        Picker("Dot Size", selection: $mTripEntity.dotSize) {
                            Text("Small").tag(theMap_ViewModel.DEFAULT_MAP_DOT_SIZE / 2)
                            Text("Medium").tag(theMap_ViewModel.DEFAULT_MAP_DOT_SIZE)
                            Text("Large").tag(theMap_ViewModel.DEFAULT_MAP_DOT_SIZE * 2)
                        }
                        .pickerStyle(.segmented)
                    } // HStack
                
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
                    
                    // Dashboard
                        HStack {
                            VStack(alignment: .leading) { // Column 1
                                Text("Distance: \(theMap_ViewModel.getTripDistanceSpeedElapsedTimeAndFuelCost(theTrip: mTripEntity).distance)")
                                Text("Avg Speed: \(theMap_ViewModel.getTripDistanceSpeedElapsedTimeAndFuelCost(theTrip: mTripEntity).speed)")
                            }
                            Spacer()
                            VStack(alignment: .leading) { // Column 2
                                Text("Elapsed Time: \(theMap_ViewModel.getTripDistanceSpeedElapsedTimeAndFuelCost(theTrip: mTripEntity).elapsedTime)")
                                Text("Fuel Cost: \(theMap_ViewModel.getTripDistanceSpeedElapsedTimeAndFuelCost(theTrip: mTripEntity).fuelCost)")
                            }
                        }
                            .font(.footnote) // .caption2, .caption, .footnote smallest to largest
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                } // VStack
                
                Spacer()
                HStack {
                    Button(action: {
                        handleShareButton()
                    }) { // Button Label parameter
                        VStack {
                            HStack {
                                Image(systemName: "square.and.arrow.up") // Share Label Image
                                    .font(.system(size:20))
                                    Text("Share") // Label Text
                                    .font(.headline)
                            } // HStack
                        } // VStack
                    } // Button Label parameters
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    Text("Export Journal Entries and Photos that were added between this trip's Start Time and End Time.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.caption) // wdhx
                        //    Fonts Smallest to Largest
                        //    Text("ABCDefg caption2").font(.caption2)
                        //    Text("ABCDefg caption").font(.caption)
                        //    Text("ABCDefg footnote").font(.footnote)
                        //    Text("ABCDefg subheadline").font(.subheadline)
                        //    Text("ABCDefg callout").font(.callout)
                        //    Text("ABCDefg body").font(.body)
                        //    Text("ABCDefg title3").font(.title3)
                        //    Text("ABCDefg title2").font(.title2)
                        //    Text("ABCDefg title").font(.title)
                } // HStack
//                Spacer()
            } // ScrollView
        } // Outermost VStack
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
        .padding()
    } // View
    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
    }
    
    func HandleOnDisappear() {
        mTripEntity.save()
        theMap_ViewModel.requestMapDotAnnotationRefresh()
    }

    func handleShareButton() {
        MyLog.debug("Export Trip handleShareButton tapped")
        theMap_ViewModel.exportTrip(tripEntity: mTripEntity)
    }
    
}

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailsView(theTripEntity: TripEntity(), mapViewModel: Map_ViewModel())
    }
}


