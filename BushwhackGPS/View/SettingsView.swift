//
//  SettingsView.swift
//  BushwhackGPS
//
//  Created by William Hause on 4/9/22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var mSettings: AppSettingsEntity
    
    private var theMap_ViewModel: Map_ViewModel
    
    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel

        _mSettings = StateObject(wrappedValue: AppSettingsEntity.getAppSettingsEntity())
    }
    
    // How to FORCE Input Fields to be Floating Point etc.
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-format-a-textfield-for-numbers
    
    // Nice Looking Animated Input Controls with Animation
    // https://www.youtube.com/watch?v=Sg0rfYL3utI
    
    // How to validate Input - Form Validation
    // https://www.youtube.com/watch?v=kl7LgoBuphM
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Settings")
                .font(.title)
                
            Picker("Metric or British Units?", selection: $mSettings.metricUnits) {
                Text("Metric Units").tag(true)
                Text("British Units").tag(false)
            }
            .pickerStyle(.segmented)
            
            Spacer()
            
            let instructions = "The Trip Cost displayed in the Dashboard, is calculated based on your vehicle's MPG and the cost of gas."
            Text(instructions).font(.caption)
    Next create MPG input forced to be a float or int https://www.hackingwithswift.com/quick-start/swiftui/how-to-format-a-textfield-for-numbers
            
            
            VStack(alignment: .leading) {
                if mSettings.metricUnits {
                    Text("Metric Units")
                } else {
                    Text("British Units")
                }
                Text("MPG: \(mSettings.mpg)")
                Text("Gas Price: \(mSettings.gasPrice)")
                if mSettings.orientNorth {
                    Text("Orient North")
                } else {
                    Text("Orient In Heading Direction")
                }
            } .padding(EdgeInsets(top: 200, leading: 0, bottom: 0, trailing: 0)) // VStack
        } .padding() // VStack
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }

    }
    
    private func HandleOnAppear() {
        MyLog.debug("Settings HandleOnAppear() called")
    }
    private func HandleOnDisappear() {
        MyLog.debug("Settings HandleOnDisappear() called")
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(mapViewModel: Map_ViewModel())
    }
}
