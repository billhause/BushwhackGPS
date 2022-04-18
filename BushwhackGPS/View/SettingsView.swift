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
    @State var deleteMeNow: String = ""
    @State var deleteMeToo: String = ""
    
//    let mMetricGasPriceLabel = "Gas Price Per Liter:"

    private var theMap_ViewModel: Map_ViewModel
    
    private let LEFT_COLUMN_WIDTH = 180.0
    
    // TODO: Move calculations into the ViewModel instead of the view
    
    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel
        _mSettings = StateObject(wrappedValue: AppSettingsEntity.getAppSettingsEntity())
        
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
                    Text(theMap_ViewModel.getSettingsMPGLabel(theSettings: mSettings))
                        .frame(minWidth: LEFT_COLUMN_WIDTH, idealWidth: LEFT_COLUMN_WIDTH, maxWidth: LEFT_COLUMN_WIDTH, alignment: .leading)
                    TextField(theMap_ViewModel.getSettingsMPGLabel(theSettings: mSettings), value: $mSettings.mpg, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 0, maxWidth: 75, minHeight: 0, maxHeight: .none, alignment: .leading)
                    Spacer()
                }

                HStack {
                    Text(theMap_ViewModel.getSettingsGasPriceLabel(theSettings: mSettings))
                        .frame(minWidth: LEFT_COLUMN_WIDTH, idealWidth: LEFT_COLUMN_WIDTH, maxWidth: LEFT_COLUMN_WIDTH, alignment: .leading)
                    TextField(theMap_ViewModel.getSettingsGasPriceLabel(theSettings: mSettings),
                              value: $mSettings.gasPrice, format: .number)
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
        mSettings.save()
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(mapViewModel: Map_ViewModel())
    }
}

struct PrettyTextInput: View {
    var title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text // must use the wrapped name _text because it's a @Binding
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
            // use grey placeholder color and switch to acceent if not empty
                .foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor)
            // Move the prompt text up 25 if the field isn't empty
                .offset(y: text.isEmpty ? 0 : -25) // move text up if value is empty
            // shrink the prompt text a bit when field is not empty
                .scaleEffect(text.isEmpty ? 1.0 : 0.8, anchor: .leading) // 80% if not empty
            TextField("", text: $text)
        }
        .padding(.top, 15) // Ad some padding to make room for the prompt to float up
        .animation(.default)
    }
}
