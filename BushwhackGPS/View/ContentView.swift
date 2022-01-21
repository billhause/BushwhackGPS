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
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack {
                Text("Bongo")
                MapView(theMap_ViewModel: theMap_ViewModel)
            } // VStack
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Picker("What kind of map do you want", selection: $theMap_ViewModel.isHybrid) {
                        Text("Hybrid").tag(true)
                        Text("Standard").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: theMap_ViewModel.isHybrid) { value in
//                        print("Hybrid Picker Called \(value)")
                    }
                    
                    Button(action: orientMap) {
                        // TODO: Fix the AttributeCycle run-time warning when clicking the orient button.  This doesn't happen in CarFinder
                        let theColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
                        let imageString = theMap_ViewModel.getOrientMapImageName()
                        Label("Follow", systemImage: imageString)
                            .foregroundColor(Color(theColor))
                    } //.font(.largeTitle) .padding()
                        .labelStyle(HorizontalLabelStyle())
                    
                }
            }
            // Detect moving back to foreground
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                theMap_ViewModel.orientMap() // Re-orient map when app moves back to the foreground
                AppSettingsEntity.getAppSettingsEntity().incrementUsageCount() // Count usage to know when to display the request for a review
                MyLog.debug("Moved back to foreground wdh")
            }
        } // NavigationView
    }

    private func orientMap() {
        withAnimation {
            Haptic.shared.impact(style: .heavy)
            theMap_ViewModel.orientMap() // Call intent function
        }
    }

}

// MARK: Custom Label Styles
struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon.font(.headline)
            configuration.title.font(.subheadline)
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
