//
//  ImagePicker.swift
//  BushwhackGPS
//
//  Created by William Hause on 4/7/22.
//

import Foundation
import UIKit
import SwiftUI

// Use the camera or Photo Library to select an image
// Specify .photoLibrary or .camera in the constructor for the ImagePicker View/
//   E.g. ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
//   NOTE: If useing .camera, you must have a line in your Info.plist to ask the user
//         for permission to use the camera.
//         E.g. "Privacy - Camera Usage Description" should be set to "Need to access the camera for taking photos"


struct ImagePicker: UIViewControllerRepresentable {
    // Add typealias temporarily so XCode could flesh out the other Protocol funcs for this type of UIViewControllerRepresentable
    // typealias UIViewControllerType = UIImagePickerController
    var sourceType: UIImagePickerController.SourceType = .photoLibrary // .photoLibrary or .camera is passed in when constructed
    
    @Binding var selectedImage: UIImage // Store the selected image in this var reference that was passed in the init() from the ContentView
    @Environment(\.presentationMode) private var presentationMode // used to dismiss the ImagePicker view
    
    func makeUIViewController(context: Context) -> UIImagePickerController { // Required for UIViewRepresentable Protocol
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType // defined as a member var above Camera vs Photo Library
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // let us update the view controller when some SwiftUI state changes
        print("ImagePicker.updateUIViewController() Called wdh")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self) // an instance of the nexted Coordinator class to contain call-backs
    }
    

    // Nested Coordinator Class
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker // The class that contains this one.  I.e. the ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent // save a copy of the parent struct
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // called when an imager is selected
            print("Coordinator.imagePickerController(didFinishPickingMediaWithInfo) called wdh")
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { // Typecast to UIImage
                // If image is not nil, then do this
                parent.selectedImage = image // save the selected image in the parent 'ImagePicker' selectedImage var
                // I think this is where you would add code to save the image to a file etc.
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    
    
}



