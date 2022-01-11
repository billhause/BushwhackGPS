//
//  BushwhackGPSApp.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/11/22.
//

import SwiftUI

@main
struct BushwhackGPSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
