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
    
    @ObservedObject var mAppSettingsEntity: AppSettingsEntity // Tracks the marker sort order
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MarkerEntity.sortOrder, ascending: false)],
        animation: .default)
    private var markerEntities: FetchedResults<MarkerEntity>

    private var theMap_ViewModel: Map_ViewModel

    init(mapViewModel: Map_ViewModel) {
        theMap_ViewModel = mapViewModel
        mAppSettingsEntity = AppSettingsEntity.getAppSettingsEntity()
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
                                Text("Distance: \(theMap_ViewModel.getDisplayableDistanceFromCurrentLocation(markerEntity.lat, markerEntity.lon))")
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
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Text("Sort Order: ")
                        Picker("Sorting order", selection: $mAppSettingsEntity.wrappedMarkerListSortOrder) {
                            Text("Date").tag("Date")
                            Text("Name").tag("Name")
                            Text("Distance").tag("Distance")
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: mAppSettingsEntity.wrappedMarkerListSortOrder) { tag in
                            theMap_ViewModel.sortMarkerEntities(by: tag) // wdhx
                            Haptic.shared.impact(style: .heavy)
                        }
                    }
                }

            } // toolbar
            .navigationTitle("Journal Marker List") // Title displayed above list
//            .navigationBarTitleDisplayMode(.inline) // Put title on same line as buttons
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
        
        // Must always resort before displaying because we might be
        // sorting by distance and be in a new location
        let sortType = AppSettingsEntity.getAppSettingsEntity().wrappedMarkerListSortOrder
        theMap_ViewModel.sortMarkerEntities(by: sortType) // wdhx
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


