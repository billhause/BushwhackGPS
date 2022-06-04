//
//  MarkerDetailsView.swift
//  BushwhackGPS
//
//  Created by William Hause on 5/31/22.
//

import SwiftUI
import CoreData
import CoreLocation

struct MarkerDetailsView: View {
    // Constants
    let BUTTON_CORNER_RADIUS  = 10.0
    let BUTTON_HEIGHT         = 30.0
    let BUTTON_FONT_SIZE      = 15.0
    let MIN_PHOTO_LIST_HEIGHT = 500.0

    // NOTE: We can't initialize the @FetchRequest predicate because the MarkerEntity is passed
    // in to the init().  Therefore we need to construct the FetchRequest in the init()
    @FetchRequest var imageEntities: FetchedResults<ImageEntity>
    
    @ObservedObject var theMap_ViewModel: Map_ViewModel

    @State var mMarkerEntity: MarkerEntity // non-nil if we are editing an existing marker
    @State private var tempUIImage = UIImage() // Temp Image Holder
    @State private var bShowPhotoLibrary = false // toggle picker view



        
    // Used when editing an EXISTING MarkerEntity and not creating a new one
    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
        theMap_ViewModel = theMap_VM
        
        // NOTE: PropertyWrapper Structs must be accessed using the underbar '_' version of the struct
        // Put an '_' in front of the variable names to access them directly.
        _mMarkerEntity = State(initialValue: markerEntity) // Variable 'self.mMarkerEntity' used before being initialized
        
        // LOAD THE IMAGES
        // Must Setup the Predecate for the Fetch Request in the init()
        //    See Stanford Lesson 12 at 1:02:20
        //    https://www.youtube.com/watch?v=yOhyOpXvaec
        let request = NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
        request.predicate = NSPredicate(format: "marker = %@", markerEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)] // Put newest at top
        _imageEntities = FetchRequest(fetchRequest: request) // Use '_' version to access wrapped variable
    }

    
    // TODO: Factor out the common views from ExistingMarkerView, MarkerDetailsView and NewMarkerView
    
    var body: some View {
        
// wdhx        Next Step: Flesh out the MarkerDetailsView based on the ExistingMarkerEditView
        
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                // vvv Share Button vvv
                Button(action: handleShareButton) {
                    let exportImageName = theMap_ViewModel.getExportImageName()
                    Label("Send a Copy", systemImage: exportImageName)
                        .foregroundColor(.accentColor)
                } // .font(.system(size: 25.0))
                    .labelStyle(VerticalLabelStyle())
                // ^^^ Share Button ^^^
                
                Spacer()
                
                
                // vvv Apple Map Navigation Button vvv
                Button(action: handleMapDirectionsButton) {
                    let mapDirectionsImageName = theMap_ViewModel.getNavigationImageName()
                    Label("Get Directions", systemImage: mapDirectionsImageName)
                        .foregroundColor(.accentColor)
                } // .font(.system(size: 25.0))
                    .labelStyle(VerticalLabelStyle())
                // ^^^ Apple Map Navigation Button ^^^
                Spacer()
            } // HStack - Share and Directions buttons
            
            
            // We must scroll to avoid overwriting the nav controls at the
            // top and because this is a tall view with a list of photos
            ScrollView {
                // TITLE
                TextDataInput(title: "Title", userInput: $mMarkerEntity.wrappedTitle)
                
                
                // Icon Picker and Color Picker
                HStack {
                    Text("Map Icon:")
                    Picker("mapIcon", selection: $mMarkerEntity.wrappedIconName) {
                        ForEach(theMap_ViewModel.getMarkerIconList(), id: \.self) {
                            Label("", systemImage: $0)
                        }
                    }
                    Spacer()
                    Text("Icon Color")
                    ColorPicker("Icon Color", selection: $mMarkerEntity.wrappedColor, supportsOpacity: false)
                        .labelsHidden() // Don't show the label, use the Text Label instead
                } // HStack - Icon Picker and Color Picker
                
                
                // DESCRIPTION
                TextDataInputMultiLine(title: "Description", userInput: $mMarkerEntity.wrappedDesc)
                
                
                // TIME STAMP, LATITUDE, LONGITUDE
                Group {
                    // Date/Time Display
                    HStack {
    //                    Text("Time Stamp: \(mMarkerEntity.wrappedTimeStamp)") // Time with seconds
                        Text("Time Stamp: \(Utility.getShortDateTimeString(theDate: mMarkerEntity.wrappedTimeStamp))") // Time with seconds
                        Spacer()
                    }
                    
                    // LAT/LON Display
                    HStack {
                        Text("Latitude: \(mMarkerEntity.lat)")
                        Spacer()
                    }
                    HStack {
                        Text("Longitude: \(mMarkerEntity.lon)")
                        Spacer()
                    }
                } // Group
                

                // PHOTOS
                Button(action: {
                    self.bShowPhotoLibrary = true
                }) {
                    // Add Photo Button View
                    HStack {
                        Spacer()
                        HStack {
                            Image(systemName: "photo") // Label Image Name
                                .font(.system(size: BUTTON_FONT_SIZE))
                            Text("Add Photo") // Label Text
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: BUTTON_HEIGHT, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(BUTTON_CORNER_RADIUS)
    //                    .padding()
                        Spacer()
                    } // HStack
                    .sheet(isPresented: $bShowPhotoLibrary, onDismiss: handleAddPhotoButton) {
                        ImagePicker(sourceType: .photoLibrary, selectedImage: $tempUIImage)
                    }
                } // Add Photo Button
                .padding(SwiftUI.EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))

                // Photo List
                List {
                    ForEach(imageEntities) {theImageEntity in
                        Image(uiImage: theImageEntity.getUIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .edgesIgnoringSafeArea(.all)
                    } // ForEach
                    .onDelete(perform: deleteItems)
                } // List
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: MIN_PHOTO_LIST_HEIGHT, maxHeight: .infinity, alignment: .center)

            } // ScrollView

            
        } // VStack - Outer Wrapper
        .navigationTitle("Journal Entry") // Title at top of page
        .padding()
        .onAppear {handleOnAppear()}
        .onDisappear {handleOnDisappear()}

    } // var body: some View
    
    
    func handleShareButton() {
        MyLog.debug("handleShareButton() called")

        // Got to get the ViewController that should present the child ViewController
        // https://stackoverflow.com/questions/32696615/warning-attempt-to-present-on-which-is-already-presenting-null
        // https://stackoverflow.com/questions/56533564/showing-uiactivityviewcontroller-in-swiftui
        //        Check out the 61 approved solution for SwiftUI calling UIActivityViewController AND the 15 approved addition to it.
        //        Also Check this out to get the Top ViewController 360 up votes
        // https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller/26667122#26667122
                                                        
        DispatchQueue.main.async { // Not sure it this helps or hurts
            theMap_ViewModel.exportJournalMarker(markerEntity: mMarkerEntity)
        }
    }
    
    func handleMapDirectionsButton() {
        let lat = mMarkerEntity.lat
        let lon = mMarkerEntity.lon
        Utility.appleMapDirections(lat: lat, lon: lon)
        MyLog.debug("MarkerDetailsView: Opening Apple Map Directions for lat:\(lat), lon:\(lon)")
    }

    // Handlers
    
    func handleOnDisappear() {
        Haptic.shared.impact(style: .heavy)
        theMap_ViewModel.setMarkerIDForRefresh(markerID: mMarkerEntity.id) // refresh the map
        MarkerEntity.saveAll()
    }
    
    func handleOnAppear() {
        Haptic.shared.impact(style: .heavy)
    }

    func handleAddPhotoButton() { // called with the Add Photo button is tapped
        MyLog.debug("ExistingMarkerView.handleAddPhotoButton() tapped")
        
        // Create a new ImageEntity for this MarkerEntity
        let newImageEntity = ImageEntity.createImageEntity(theMarkerEntity: mMarkerEntity)
        
        // Set the ImageEntity imageData and save
        newImageEntity.setImageAndSave(tempUIImage)
    }
    
    private func deleteItems(offsets: IndexSet) {
        MyLog.debug("ExistingMarkerView.deleteItems() Called \(offsets)")
        let viewContext = PersistenceController.shared.container.viewContext
        withAnimation {
            offsets.map { imageEntities[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    
} // MarkerDetailsView struct

struct MarkerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        MarkerDetailsView(theMap_VM: Map_ViewModel(), markerEntity: MarkerEntity())
    }
}
