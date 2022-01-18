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
                Text("Banana")
            } // VStack
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(theMap_ViewModel: Map_ViewModel()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
