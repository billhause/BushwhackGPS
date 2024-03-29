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
    
    @State var stateTripEntities: [TripEntity] = []
    
    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel
    }

//Look at this to see a similar example to pull values out of the array
//https://stackoverflow.com/questions/56615918/how-do-i-set-the-toggle-state-in-a-foreach-loop-in-swiftui/56616127#56616127
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach($stateTripEntities) { tripEntity in
                    NavigationLink {
                        TripDetailsView(theTripEntity: tripEntity.wrappedValue, mapViewModel: theMap_ViewModel)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(uiImage: theMap_ViewModel.getDotUIImageForTripList(tripEntity: tripEntity.wrappedValue))
                                    //                                    .resizable()
                                    //                                    .scaledToFill()
                                    //                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    //                                    .edgesIgnoringSafeArea(.all)
                                    Text(tripEntity.wrappedValue.wrappedTitle) // wrappedValue dereferences the @State var from Binding<> to the value
                                }
                                Text("   \(theMap_ViewModel.getShortDateTimeString(theDate: tripEntity.wrappedStartTime.wrappedValue)) - \(theMap_ViewModel.getShortDateTimeString(theDate: tripEntity.wrappedEndTime.wrappedValue))")
                                    .font(.footnote)
                            }
                            Spacer() // Push the switch column to the right side
                            // Hide/Show Slider with no labvel
                            Toggle(isOn: tripEntity.showTripDots) {
                                Text("Hide/Show")
                            } .labelsHidden()
                        } // HStack
                    }
                } // ForEach
                .onDelete(perform: deleteTripEntities)
            } // List
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
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
            let newTrip = TripEntity.createTripEntity(dotSize: theMap_ViewModel.DEFAULT_MAP_DOT_SIZE) // avoid single line return warning with _=
            
            // Must also add the entity to the stateTripEntities array since that's what were using to display the list
            stateTripEntities.insert(newTrip, at: 0) // add to beginning of array
            
        } // withAnimation

    }
    
    private func deleteTripEntities(offsets: IndexSet) {
        withAnimation {
            offsets.map { tripEntities[$0] }.forEach(viewContext.delete)
            
            // NOTE: Must also delete the entities from the stateTripEntities array
            // Uses the extension below "mutating func remove(at indexes : IndexSet)" to delete them
            // Obtained from here: https://stackoverflow.com/questions/26173565/removeobjectsatindexes-for-swift-arrays
            stateTripEntities.remove(at: offsets)
            
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
        MyLog.debug("HandleOnAppear() Called for TripListView")
    }
    
    func HandleOnDisappear() {
        MyLog.debug("HandleOnDisappear() Called for TripListView")
        theMap_ViewModel.requestMapDotAnnotationRefresh()

        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving in TripListView.HandleOnDisappear() \(nsError.userInfo)")
        }

    }

    
    
} // TripListView Struct



struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
        TripListView(mapViewModel: Map_ViewModel())
    }
}

// Used To remove the elements in the list when the user selects Delete
extension RangeReplaceableCollection where Self: MutableCollection, Index == Int {

    mutating func remove(at indexes : IndexSet) {
        guard var i = indexes.first, i < count else { return }
        var j = index(after: i)
        var k = indexes.integerGreaterThan(i) ?? endIndex
        while j != endIndex {
            if k != j { swapAt(i, j); formIndex(after: &i) }
            else { k = indexes.integerGreaterThan(k) ?? endIndex }
            formIndex(after: &j)
        }
        removeSubrange(i...)
    }
}
