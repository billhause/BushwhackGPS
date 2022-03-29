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
    
    init(theViewModel: Map_ViewModel) {
        theMap_ViewModel = theViewModel
        theAppSettingsEntity = AppSettingsEntity.getAppSettingsEntity()
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
                    Text("Odometer: \(DashboardEntity.getDashboardEntity().displayOdometer())")
                    Text("Avg Speed: \(DashboardEntity.getDashboardEntity().displayAvgSpeed())")
                }
                Spacer()
                VStack(alignment: .leading) { // Column 2
                    Text("Start Time: \(DashboardEntity.getDashboardEntity().displayStartTime())")
                    Text("Elapse: \(DashboardEntity.getDashboardEntity().displayElapseTime())")
                }
            }
                .font(.footnote) // .caption2, .caption, .footnote smallest to largest
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))

            HStack {
                Button("Dashboard Reset") {
                    handleResetButton()
                } // VStack
                Spacer()
                Button("Save As Trip") {
                    handleSaveAsTrip()
                }
            }
        } //.background(Color.yellow)
    }
    
    private func handleSaveAsTrip() {
        MyLog.debug("Save As Trip Pressed")
    }
    private func handleResetButton() {
        MyLog.debug("Reset Pressed")
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(theViewModel: Map_ViewModel())
    }
}
