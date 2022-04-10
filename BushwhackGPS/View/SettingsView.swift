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
    var mGasPriceLabel = "Gas Price:"
    var mMPGLabel = "Vehicle MPG:"
//    var mMPGBritishLabel = "Vehicle Miles Per Liter:"
    var mMetricGasPriceLabel = "Gas Price Per Liter:"
    var mMetricMPGLabel = "Vehicle km per Liter"

    private var theMap_ViewModel: Map_ViewModel
    
    private let LEFT_COLUMN_WIDTH = 180.0
    
    // TODO: Move calculations into the ViewModel instead of the view
    
    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel
        _mSettings = StateObject(wrappedValue: AppSettingsEntity.getAppSettingsEntity())
        
        // Setup labels for Great Britian, US and Generic Metric Countries
        // Great Britian uses Miles (not km) and Liters
        let countryCode = NSLocale.current.regionCode
        if countryCode == "US" {
//            MyLog.debug("CountryCode is US: \(countryCode)")
            mGasPriceLabel = "Gas Price ($):"
            mMPGLabel = "Vehicle MPG:"
        } else if countryCode == "GB" {
            mGasPriceLabel = "Gas Price Per Liter (£):"
            mMPGLabel = "Vehicle Miles Per Liter:"
        }

    }
    
    // How to FORCE Input Fields to be Floating Point etc.
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-format-a-textfield-for-numbers
    
    // TODO: Make text fields look professional - See video below
    // Nice Looking Animated Input Controls with Animation
    // https://www.youtube.com/watch?v=Sg0rfYL3utI
    
    // How to validate Input - Form Validation
    // https://www.youtube.com/watch?v=kl7LgoBuphM
    
    // Format TextFields for numbers
    //https://www.hackingwithswift.com/quick-start/swiftui/how-to-format-a-textfield-for-numbers

 wdhx Next: Move display logic into ViewModel
    
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

            VStack(alignment: .leading, spacing: 0) {
                let instructions = "The Trip's Fuel Cost is displayed on the Dashboard. It is calculated based on your vehicle's MPG and the cost of gas."
                Text(instructions).font(.caption)

                HStack {
                    if mSettings.metricUnits {
                        Text(mMetricMPGLabel)
                            .frame(minWidth: LEFT_COLUMN_WIDTH, idealWidth: LEFT_COLUMN_WIDTH, maxWidth: LEFT_COLUMN_WIDTH, alignment: .leading)
                    } else {
                        Text(mMPGLabel)
                            .frame(minWidth: LEFT_COLUMN_WIDTH, idealWidth: LEFT_COLUMN_WIDTH, maxWidth: LEFT_COLUMN_WIDTH, alignment: .leading)
                    }
                    TextField(mMPGLabel, value: $mSettings.mpg, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: .none, alignment: .leading)
                    Spacer()
                }

                HStack {
                    Text(mGasPriceLabel)
                        .frame(minWidth: LEFT_COLUMN_WIDTH, idealWidth: LEFT_COLUMN_WIDTH, maxWidth: LEFT_COLUMN_WIDTH, alignment: .leading)
                    TextField("Gas Price", value: $mSettings.gasPrice, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: .none, alignment: .leading)
                    Spacer()
                }
                Spacer()
            } // VStack - Instructions, MPG, Gas Price

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
