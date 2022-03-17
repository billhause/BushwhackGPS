//
//  TripListView.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/16/22.
//

import SwiftUI
import CoreData

struct TripListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TripEntity.startTime, ascending: false)],
        animation: .default)
    private var tripEntities: FetchedResults<TripEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tripEntities) { tripEntity in
                    NavigationLink {
                        TripDetailsView(theTripEntity: tripEntity)
                    } label: {
                        Text(tripEntity.title!) // Displayed in list
                    }
                } // ForEach
                .onDelete(perform: deleteTripEntities)
            } // List
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: addTripEntity) {
                        Label("New Trip", systemImage: "plus")
                            .labelStyle(TitleOnlyLabelStyle())  // Shows the Text, not the systemImage
                    }
                }
                
            } // toolbar
            .navigationTitle("Trip List") // Title displayed above list
            .navigationBarTitleDisplayMode(.inline) // Put title on same line as buttons
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle()) // Needed to avoid run-time warnings related to .navigationTitle
        
    }

    private func addTripEntity() {
        withAnimation {
            _ = TripEntity.createTripEntity() // avoid single line return warning with _=
        } // withAnimation
    }
    
    private func deleteTripEntities(offsets: IndexSet) {
        withAnimation {
            offsets.map { tripEntities[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("wdh Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } // withAnimation
    }
} // TripListView Struct



struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView()
    }
}
