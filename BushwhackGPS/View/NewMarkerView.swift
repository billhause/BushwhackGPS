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
        MyLog.debug("*** init() called for NewMarkerView")
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
                Text("Insufficient Location Accuracy to create a reliable Journal Entry Point")
                    .padding()
                Text("Wait for better Location Accuracy and try again")
                    .padding()
            } else {
                MarkerEditView(theMap_VM: theMap_ViewModel)
            }
        }
    }
}

// It's safe to assume we have an Accurate Location for this view because we
// already checked in the parrent view
struct MarkerEditView: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
        
    init(theMap_VM: Map_ViewModel) {
        theMap_ViewModel = theMap_VM
    }
    var body: some View {
        VStack {
            Text("Contineu Here")
        }
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
    }
    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        Haptic.shared.impact(style: .heavy)
        MyLog.debug("1 HandleOnAppear() called")
    }
    func HandleOnDisappear() {
        MyLog.debug("3 HandleOnDisappear() called")
    }
    
}


struct MarkerEditView_Previews: PreviewProvider {
    static var previews: some View {
        MarkerEditView(theMap_VM: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
