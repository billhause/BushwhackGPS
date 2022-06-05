//
//  MarkerListView.swift
//  BushwhackGPS
//
//  Created by William Hause on 5/30/22.
//

import SwiftUI
import CoreData

struct MarkerListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MarkerEntity.timestamp, ascending: false)],
        animation: .default)
    private var markerEntities: FetchedResults<MarkerEntity>
    private var theMap_ViewModel: Map_ViewModel

    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(markerEntities) { markerEntity in
                    NavigationLink {
                        MarkerDetailsView(theMap_VM: theMap_ViewModel, markerEntity: markerEntity)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(markerEntity.wrappedTitle)
                            HStack {
Replace this with the actual distance
                                Text("Distance: 2.3 miles")
                                    .font(.footnote)
                                Spacer()
                                Text(theMap_ViewModel.getShortDateTimeString(theDate: markerEntity.wrappedTimeStamp))
                                    .font(.footnote)
                            }
                            // Hide/Show Slider with no labvel
//                            Text(markerEntity.wrappedDesc.prefix(100))
                            Text(getDisplayDesc(markerEntity.wrappedDesc))
                                .font(.footnote)
                        } // HStack
                    }
                } // ForEach
                .onDelete(perform: deleteMarkerEntities)
            } // List
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }

            } // toolbar
            .navigationTitle("Journal Marker List") // Title displayed above list
            .navigationBarTitleDisplayMode(.inline) // Put title on same line as buttons
        } // NavigationView
        .navigationViewStyle(StackNavigationViewStyle()) // Needed to avoid run-time warnings related to .navigationTitle
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }

    }

    private func deleteMarkerEntities(offsets: IndexSet) {
        offsets.map {
            markerEntities[$0]
        }.forEach() { currentMarker in
            // ID For Deletion:
            let idForDeletion = currentMarker.id
            theMap_ViewModel.setMarkerIDForDeletion(markerID: idForDeletion) // There will be only one to delete
        }


        withAnimation {
            offsets.map { markerEntities[$0] }.forEach(viewContext.delete)
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
        MyLog.debug("HandleOnAppear() Called for MarkerListView")
    }
    
    func HandleOnDisappear() {
        MyLog.debug("HandleOnDisappear() Called for MarkerListView")
//        theMap_ViewModel.requestMapDotAnnotationRefresh()

        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving in MarkerListView.HandleOnDisappear() \(nsError.userInfo)")
        }
    }
    
    let MAX_DISP_LEN = 150
    func getDisplayDesc(_ theText: String) -> String {
        if theText.count == 0 {
            return ""
        } else if theText.count < MAX_DISP_LEN {
            return theText
        }
        return theText.prefix(MAX_DISP_LEN) + " ..."
    }

}


