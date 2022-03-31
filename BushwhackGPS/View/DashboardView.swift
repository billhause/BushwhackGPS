//
//  DashboardView.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/28/22.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    @ObservedObject var theAppSettingsEntity: AppSettingsEntity // The AppSettingsEntity is like a tiny view model
    @ObservedObject var theDashboardEntity: DashboardEntity
    
    @State private var showingDashboardResetConfirm = false // flag for Reset Confirm dialog
    @State private var showingSaveAsTripConfirm = false // flag for confirm save as trip dialog

    init(theViewModel: Map_ViewModel) {
        theMap_ViewModel = theViewModel
        theAppSettingsEntity = AppSettingsEntity.getAppSettingsEntity()
        theDashboardEntity = DashboardEntity.getDashboardEntity()
    }
    
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

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) { // Column 1
                    Text("Odometer: \(theDashboardEntity.displayableOdometer())")
                    Text("Avg Speed: \(theDashboardEntity.displayableAvgSpeed())")
                }
                Spacer()
                VStack(alignment: .leading) { // Column 2
                    Text("Start Time: \(theDashboardEntity.displayableStartTime())")
                    Text("Elapsed: \(theDashboardEntity.displayableElapsedTime())")
                }
            }
                .font(.footnote) // .caption2, .caption, .footnote smallest to largest
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))

            HStack {
                Button("Dashboard Reset") {
                    showingDashboardResetConfirm = true // show the confirm dialog
                } // VStack
                .alert(isPresented: $showingDashboardResetConfirm) {
                    Alert(
                        title: Text("Confirm Dashboard Reset"),
                        message: Text("This cannot be undone."),
                        primaryButton: .destructive(Text("Reset")) {
                            handleResetButton()
                        },
                        secondaryButton: .cancel()
                    )
                }

                Spacer()
                Button("Save As Trip") {
                    showingSaveAsTripConfirm = true // show the confirm dialog
                }
                .alert(isPresented: $showingSaveAsTripConfirm) {
                    Alert(
                        title: Text("Save the Dashboard and it's map points as a Trip and reset the dashboard.  "),
                        message: Text("The saved Trip will be named using the Dashboard start date."),
                        primaryButton: .destructive(Text("Save as Trip and Reset")) {
                            handleSaveAsTrip()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        } //.background(Color.yellow)
    }
    
    private func handleSaveAsTrip() {
        MyLog.debug("Save As Trip Pressed")
        theMap_ViewModel.createTripFromDashboard()
        DashboardEntity.getDashboardEntity().resetDashboard()
        theMap_ViewModel.requestMapDotAnnotationRefresh()
    }
    
    private func handleResetButton() {
        MyLog.debug("Reset Pressed")
        DashboardEntity.getDashboardEntity().resetDashboard()
        theMap_ViewModel.requestMapDotAnnotationRefresh()
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(theViewModel: Map_ViewModel())
    }
}
