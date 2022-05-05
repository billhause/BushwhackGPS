//
//  ExistingMarkerView.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/5/22.
//

import Foundation
import SwiftUI
import CoreLocation
import CoreData


// It's safe to assume we have an Accurate Location for this view because we
// already checked in the parrent view
struct ExistingMarkerEditView: View {
    // Constants
    let BUTTON_CORNER_RADIUS  = 10.0
    let BUTTON_HEIGHT         = 30.0
    let BUTTON_FONT_SIZE      = 15.0
    let MIN_PHOTO_LIST_HEIGHT = 500.0

    // NOTE: We can't initialize the @FetchRequest predicate because the MarkerEntity is passed
    // in to the init().  Therefore we need to construct the FetchRequest in the init()
    @FetchRequest var imageEntities: FetchedResults<ImageEntity>
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \ImageEntity.timeStamp, ascending: true)],
//        animation: .default)
//    private var imageEntities: FetchedResults<ImageEntity>
    
    @ObservedObject var theMap_ViewModel: Map_ViewModel
    
    @State private var showingDeleteJournalConfirm = false // Flag for Confirm Dialog
    @State private var deleteThisMarker = false // Set to true if user clicks delete
    @State private var bShowPhotoLibrary = false // toggle picker view
    @State private var tempUIImage = UIImage() // Temp Image Holder
    
    @State var mMarkerID: Int64 = 0
    @State var titleText: String = ""
    @State var bodyText: String = ""
    @State var iconSymbolName: String = "multiply.circle" //"xmark.square.fill"
    @State var lat: Double = 100.0
    @State var lon: Double = -100.0
    @State var iconColor: Color = Color(.sRGB, red: 1.0, green: 0.0, blue: 0.0) // Red by default - Satalite and Map
    @State var dateTimeDetailText = "" // Used to display the time with seconds
    @State var mMarkerEntity: MarkerEntity // non-nil if we are editing an existing marker
            
    // Constants
    let LEFT_PADDING = 10.0 // Padding on the left side of various controls
    
    // Used when editing an EXISTING MarkerEntity and not creating a new one
    init(theMap_VM: Map_ViewModel, markerEntity: MarkerEntity) {
        theMap_ViewModel = theMap_VM
        
        // NOTE: PropertyWrapper Structs must be accessed using the underbar '_' version of the struct
        // Put an '_' in front of the variable names to access them directly.
        _mMarkerEntity = State(initialValue: markerEntity) // Variable 'self.mMarkerEntity' used before being initialized
        
        // Must Setup the Predecate for the Fetch Request in the init()
        //    See Stanford Lesson 12 at 1:02:20
        //    https://www.youtube.com/watch?v=yOhyOpXvaec
        let request = NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
        request.predicate = NSPredicate(format: "marker = %@", markerEntity)
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)] // Put newest at top
        _imageEntities = FetchRequest(fetchRequest: request) // Use '_' version to access wrapped variable
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {

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
                
                Button("Done") {
                    EditExistingMarkerController.shared.showEditMarkerDialog = false // Flag that tells the dialog to close
                }
            }
            
            HStack {
//                Spacer()
                Text("Journal Entry")
                    .font(.title)
                Spacer()
            }
            .padding(.top)

            ScrollView {
                
            // Journal Entry Title and Body
            TextDataInput(title: "Title", userInput: $titleText)
                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 10, trailing: 0.0))

            // Icon Picker and Color Picker
            HStack {
                Text("Map Icon:")
                Picker("mapIcon", selection: $iconSymbolName) {
                    ForEach(theMap_ViewModel.getMarkerIconList(), id: \.self) {
                        Label("", systemImage: $0)
                    }
                } //.pickerStyle(MenuPickerStyle()) //.pickerStyle(SegmentedPickerStyle()) //.pickerStyle(WheelPickerStyle())
                Spacer()
                // Color Picker
                VStack(alignment: .leading) {
                    Text("Icon Color")
//                    Text("(Darker is Better)").font(.footnote)
                }
                ColorPicker("Icon Color", selection: $iconColor, supportsOpacity: false)
                    .labelsHidden() // don't show the label.  Use the Text lable instead

            } // HStack

                
            // Journel Entry Description
            TextDataInputMultiLine(title: "Description", userInput: $bodyText)

            // Delete Journal Entry
            HStack {
                Spacer()
                Button("Delete Journal Entry") {
                    showingDeleteJournalConfirm = true // Flag to cause dialog to display
                }
                .alert(isPresented: $showingDeleteJournalConfirm) {
                    Alert(
                        title: Text("Are you sure you want to delete this journal entry?"),
                        message: Text("This cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            // Set Flag that tells the dialog to close
                            EditExistingMarkerController.shared.showEditMarkerDialog = false
                            
                            // Set flag to delete the Marker in HandleOnDisappear() below
                            deleteThisMarker = true
                        },
                        secondaryButton: .cancel()
                    )
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 30, alignment: .center)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                Spacer()
            }
            .padding(SwiftUI.EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))


            Group {
                // Date/Time Display
                HStack {
                    Text("Time Stamp: \(dateTimeDetailText)") // Time with seconds
                    Spacer()
                }
                
                // LAT/LON Display
                HStack {
                    Text("Latitude: \(lat)")
                    Spacer()
                }
                HStack {
                    Text("Longitude: \(lon)")
                    Spacer()
                }
            } // Group
            
            
            // Add Photo Button
            Button(action: {
                self.bShowPhotoLibrary = true
            }) {
                // Button View
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
            } // Button
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

            } // Scroll View

        } // VStack
        .padding()
        .navigationTitle("New Journal Marker") // Title at top of page
        .onAppear { HandleOnAppear() }
        .onDisappear { HandleOnDisappear() }
    }

    private func deleteItems(offsets: IndexSet) {
        MyLog.debug("deleteItems() Called \(offsets)")
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

    
    // This will be called when ever the view apears
    // Calling this from .onAppear in the Body of the view.
    func HandleOnAppear() {
        Haptic.shared.impact(style: .heavy)
        MyLog.debug("HandleOnAppear() Existing Marker Entity called")
        
        // We are editing an existing Marker Entity
        // Initialize the fields based on the MarkerEntity we are editig
        mMarkerID = mMarkerEntity.id
        titleText = mMarkerEntity.title!
        bodyText = mMarkerEntity.desc!
        iconSymbolName = mMarkerEntity.iconName!
        lat = mMarkerEntity.lat
        lon = mMarkerEntity.lon
        iconColor = Color(.sRGB, red: mMarkerEntity.colorRed, green: mMarkerEntity.colorGreen, blue: mMarkerEntity.colorBlue)
        
        // Use creation date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        dateTimeDetailText = dateFormatter.string(from: mMarkerEntity.timestamp!)
    }
    
    func HandleOnDisappear() {
        Haptic.shared.impact(style: .heavy)
        
        if deleteThisMarker == false {
            theMap_ViewModel.updateExistingMarker(theMarker: mMarkerEntity, lat: self.lat, lon: self.lon, title: titleText, body: bodyText, iconName: iconSymbolName, color: iconColor)
        } else {
            theMap_ViewModel.setMarkerIDForDeletion(markerID: mMarkerID)
        }
    }
    
    func handleAddPhotoButton() { // called with the Add Photo button is tapped
        MyLog.debug("handleAddPhotoButton() tapped")
        
        // Create a new ImageEntity for this MarkerEntity
        let newImageEntity = ImageEntity.createImageEntity(theMarkerEntity: mMarkerEntity)
        
        // Set the ImageEntity imageData and save
        newImageEntity.setImageAndSave(tempUIImage)
    }
    
    func handleMapDirectionsButton() {
        let lat = mMarkerEntity.lat
        let lon = mMarkerEntity.lon
        Utility.appleMapDirections(lat: lat, lon: lon)
        MyLog.debug("Opening Apple Map Directions for lat:\(lat), lon:\(lon)")
    }
    
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
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()


struct ExistingMarkerEditView_Previews: PreviewProvider {
    static var previews: some View {
        ExistingMarkerEditView(theMap_VM: Map_ViewModel(), markerEntity: MarkerEntity.createMarkerEntity(lat: 100,lon: 100)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).previewInterfaceOrientation(.portraitUpsideDown)
    }
}



// Example Call:
//   EditMarkerController.shared.MarkerDialog(theMarkerEntityToEdit)
//
// NOTE: The ContentView must have a view that is setup to show an EditMarkerController dialog like this:
//   @StateObject var theMarkerEditDialog = EditMarkerController.shared
// AND a View (like a Spacer) with a .sheet property
//if #available(iOS 15.0, *) {
//    Spacer()
//    .sheet(isPresented:$theMarkerEditDialog.showEditMarkerDialog) {
//        MarkerEditView(theMap_VM: theMap_ViewModel, markerEntity: theMarkerEditDialog.theMarkerEntity!)
//    }
//} else {
//    // Fallback on earlier versions
//    Spacer()
//}


class EditExistingMarkerController: ObservableObject {
    static var shared = EditExistingMarkerController()
    
    // To show an alert, set theMessage and set the showAlert bool to true
    var theMarkerEntity: MarkerEntity?
    @Published var showEditMarkerDialog = false // Must be published to trigger the dialog to show
    
    func MarkerDialog(_ markerEntity: MarkerEntity) {
        theMarkerEntity = markerEntity
        showEditMarkerDialog = true
    }
    
}
