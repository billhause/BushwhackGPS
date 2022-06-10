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

