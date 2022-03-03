//
//  ContentView.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/11/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
//    @State var mDotArray = DotEntity.getAllDotEntities()
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var theAlert = AlertMessage.shared // @StateObject not @ObservedObject to avoid AttributeGraph cycle warnings
    
    var body: some View {
        NavigationView {
            VStack {
                MapView(theViewModel: theMap_ViewModel)
                
                // vvvvvvv ALERT MESSAGE vvvvvvvvv
                if #available(iOS 15.0, *) {
                    Spacer()
                        .alert(theAlert.theMessage, isPresented: $theAlert.showAlert) {
                            Button("OK", role: .cancel) { }
                        }
                } else {
                    // Fallback on earlier versions
                    Spacer()
                }
                // ^^^^^^^^^ ALERT MESSAGE ^^^^^^^^^^^^^
                
            } // VStack
//            .navigationBarHidden(true) // Remove the space for the top nav bar
            .navigationBarTitleDisplayMode(.inline) // Put title on same line as tool bar
            .toolbar {
                // TOP TOOL BAR
                ToolbarItemGroup(placement: .automatic) {
                    HStack {
                        Text("Dot Count: \(DotEntity.getAllDotEntities().count)")
                        Spacer()
                        Button(action: updateParkingSpot) {
                            let theColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                            let parkingImageName = theMap_ViewModel.getParkingLocationImageName()
                            Label("Save Spot", systemImage: parkingImageName)
                                .foregroundColor(Color(theColor))
                                .padding() // Move the Parking symbol away from right border a little bit
                        }// .font(.system(size: 25.0))
                            .labelStyle(VerticalLabelStyle())
                        
                    }
                }

                // BOTTOM TOOL BAR
                ToolbarItemGroup(placement: .bottomBar) {
                    // ViewBuilder only allows 10 static views in one container.  Must Group them
                    Group { // Group 1
                        Spacer()
                        Button(action: hideDotsHandler) {
                            let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                            let hideDotsImageName = theMap_ViewModel.getHideDotsImageName()
                            Label("Reset", systemImage: hideDotsImageName)
                                .foregroundColor(Color(theColor))
                        }
                            .labelStyle(VerticalLabelStyle())
                        Spacer()
                        Button(action: toggleMapLayers) {
                            let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                            let mapLayersImageName = theMap_ViewModel.getMapLayerImageName()
                            Label("Aerial Layer", systemImage: mapLayersImageName)
                                .foregroundColor(Color(theColor))
                        }
                            .labelStyle(VerticalLabelStyle())
//                        Spacer()
//                        Button(action: addMarkerHandler) {
//                            let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
//                            let addMarkerImageName = theMap_ViewModel.getAddJournalEntryImageName()
//                            Label("Marker", systemImage: addMarkerImageName)
//                                .foregroundColor(Color(theColor))
//                        }
//                            .labelStyle(VerticalLabelStyle())
                    } // Group 1

                    Group { // Group 2
                        Spacer()
                        NavigationLink(destination: NewMarkerView(theMap_VM: theMap_ViewModel)) {
                                let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                                let journalImageName = theMap_ViewModel.getAddJournalEntryImageName()
                                Label("Journal Marker", systemImage: journalImageName)
                                    .foregroundColor(Color(theColor))
                        }
                            .labelStyle(VerticalLabelStyle())
                        Spacer()
                        Button(action: toggleMapNorth) {
                            let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                            let compassImageName = theMap_ViewModel.getCompassImageName()
                            Label("Lock North", systemImage: compassImageName)
                                .foregroundColor(Color(theColor))
                        }
                            .labelStyle(VerticalLabelStyle())
                        Spacer()
                        Button(action: orientMap) {
                            let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                            let imageString = theMap_ViewModel.getOrientMapImageName()
                            Label("Follow", systemImage: imageString)
                                .foregroundColor(Color(theColor))
                        }
                            .labelStyle(VerticalLabelStyle())
                    } // Group 2
                } // Bottom Tool Bar
            }
            // Detect moving back to foreground
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                theMap_ViewModel.orientMap() // Re-orient map when app moves back to the foreground
                AppSettingsEntity.getAppSettingsEntity().incrementUsageCount() // Count usage to know when to display the request for a review
                MyLog.debug("** App Moved back to foreground wdh")
            }
            // Detect moving to background
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                MyLog.debug("** App Moved to Background wdh")
            }
        } // NavigationView
    }

//    private func addMarkerHandler() { // wdhx
//        theMap_ViewModel.addNewDefaultMarker()
//        Haptic.shared.impact(style: .heavy)
//    }

    private func hideDotsHandler() {
        MyLog.debug("hideDotsHandler() called")
        // Update filter to start right now so that past dots are hidden
        theMap_ViewModel.updateFilterStartDate(Date())
        Haptic.shared.impact(style: .heavy)
    }
    
    private func toggleMapLayers() {
        theMap_ViewModel.isHybrid = !theMap_ViewModel.isHybrid // toggle
        Haptic.shared.impact(style: .heavy)
    }
    
    // Called when the Orient Map button is touched
    private func orientMap() {
        withAnimation {
            Haptic.shared.impact(style: .heavy)
            theMap_ViewModel.orientMap() // Call intent function
        }
    }

    private func updateParkingSpot() {
        theMap_ViewModel.requestReview()
        Haptic.shared.impact(style: .heavy)
        withAnimation {
            theMap_ViewModel.updateParkingSpot() // Call intent function
        }
    }
    
    private func toggleMapNorth() {
        MyLog.debug("toggleMapNorth() Called")
        // Toggle the NorthFlag in the Settings Entity.
        let newOrientNorthFlag = !AppSettingsEntity.getAppSettingsEntity().orientNorth
        AppSettingsEntity.getAppSettingsEntity().setOrientNorth(always: newOrientNorthFlag)
        Haptic.shared.impact(style: .heavy)
    }

}

// MARK: Custom Label Styles
struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.headline)
            configuration.title.font(.system(size:8)) // very small print
//            configuration.title.font(.subheadline)
        }
    }
}
struct HorizontalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title.font(.subheadline)
            configuration.icon.font(.system(size: 24)) // .headline, .largeTitle, .subheadline,
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(theMap_ViewModel: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
