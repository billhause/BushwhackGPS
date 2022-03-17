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
    
    init(theTripEntity: TripEntity) {
        self.theTripEntity = theTripEntity
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
            Text("Trip Details")
                .font(.title)
//            TextField("Enter Title", text: $theTripEntity.wrappedTitle)
//            TextDataInput(title: "Trip Title:", userInput: $theTripEntity.wrappedTitle)
            Spacer()
        }
            .padding()
        
    }
}

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailsView(theTripEntity: TripEntity())
    }
}
