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
    private var theMap_ViewModel: Map_ViewModel
    
    @State var dummyBool: Bool = false
    @State var stateTripEntities: [TripEntity] = []
    
    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel
    }

//Look at this to see a similar example to pull values out of the array
//https://stackoverflow.com/questions/56615918/how-do-i-set-the-toggle-state-in-a-foreach-loop-in-swiftui/56616127#56616127
    
    var body: some View {
        Text("Bongos")
        NavigationView {
            List {
                ForEach($stateTripEntities) { tripEntity in
                    NavigationLink {
                        TripDetailsView(theTripEntity: tripEntity.wrappedValue, mapViewModel: theMap_ViewModel)
                    } label: {
                        Text(tripEntity.wrappedValue.wrappedTitle) // wrappedValue dereferences the @State var from Binding<> to the value
                        Toggle(isOn: tripEntity.showTripDots) {
                            Text("")
                        }
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
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }

    }

    private func addTripEntity() {
        withAnimation {
            _ = TripEntity.createTripEntity(dotSize: theMap_ViewModel.DEFAULT_MAP_DOT_SIZE) // avoid single line return warning with _=
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
    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        stateTripEntities = TripEntity.getAllTripEntities_NewestToOldest()
        MyLog.debug("stateTripEntities.count \(stateTripEntities.count)")

        MyLog.debug("HandleOnAppear() Called for TripListView")
    }
    
    func HandleOnDisappear() {
        MyLog.debug("HandleOnDisappear() Called for TripListView")
        theMap_ViewModel.requestMapDotAnnotationRefresh()
    }

    
    
} // TripListView Struct



struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView(mapViewModel: Map_ViewModel())
    }
}
