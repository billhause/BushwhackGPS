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
        sortDescriptors: [NSSortDescriptor(keyPath: \TripEntity.startTime, ascending: true)],
        animation: .default)
    private var tripEntities: FetchedResults<TripEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tripEntities) { tripEntity in
                    NavigationLink {
                        Text("TripEntity at \(tripEntity.startTime!, formatter: tripListDateFormatter)")
                    } label: {
                        Text(tripEntity.startTime!, formatter: tripListDateFormatter)
                    }
                } // ForEach
                .onDelete(perform: deleteTripEntities)
            } // List
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addTripEntity) {
                        Label("Add Trip", systemImage: "plus")
                    }
                }
            } // toolbar
            Text("Select a Trip")
        } // NavigationView
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


private let tripListDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView()
    }
}
