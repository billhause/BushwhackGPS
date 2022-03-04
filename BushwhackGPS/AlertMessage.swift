//
//  AlertMessage.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/21/22.
//

import Foundation

// Example Call:
//   AlertMessage.shared.Alert("This is the message to display with an OK button")
//
// NOTE: The ContentView must have a view that is setup to show an alert message like this:
//   @StateObject var theAlert = AlertDialog.shared
// AND a View (like a Spacer) with a .alert property
//if #available(iOS 15.0, *) {
//    Spacer()
//        .alert(theAlert.theMessage, isPresented: $theAlert.showAlert) {
//            Button("OK", role: .cancel) { }
//        }
//} else {
//    // Fallback on earlier versions
//    Spacer()
//}


class AlertMessage: ObservableObject {
    static var shared = AlertMessage()
    
    // To show an alert, set theMessage and set the showAlert bool to true
    var theMessage = "Confirm"
    var showAlert = false
    
    func Alert(_ message: String) {
        theMessage = message
        showAlert = true
    }
    
}
