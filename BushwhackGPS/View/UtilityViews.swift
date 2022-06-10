//
//  UtilityViews.swift
//  BushwhackGPS
//
//  Created by William Hause on 6/10/22.
//

import Foundation
import SwiftUI
//import CoreLocation



// Generic data input with a label and field to enter data
// Nice Looking Animated Input Controls with Animation for label
// https://www.youtube.com/watch?v=Sg0rfYL3utI
struct PrettyTextField: View {
    var title: String
    @Binding var userInput: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .zIndex(2)
                .foregroundColor(userInput.isEmpty ? Color(.placeholderText) : .accentColor)
                .offset(y: userInput.isEmpty ? 0 : -30) // move up if text is not empty
                .scaleEffect(userInput.isEmpty ? 1.0 : 0.8, anchor: .leading) // 80% size after moving up
            TextField("", text: $userInput)
                .zIndex(1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.top, 15)
        .animation(.easeInOut(duration: 0.5), value: userInput)
//        .animation(Animation.default, value: false)
//        .animation(Animation.easeInOut(duration: 1.0), value: true)
//        .animation(.default)
    }
}

// Generic data input with a label and field to enter data
struct TextDataInput: View {
    var title: String
    @Binding var userInput: String
    
    var body: some View {
        HStack {
            Text("\(title):")
        TextField("\(title)", text: $userInput)                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}


// Generic Multi-Line data input with a label and field to enter data
struct TextDataInputMultiLine: View {
    var theTitle: String
    @Binding var theUserInput: String
    var theIdealHeight: CGFloat
    
    init(title: String, userInput: Binding<String>, idealHeight: CGFloat = 100) {
        theTitle = title
        _theUserInput = userInput // The compiler wraps the var name with an underscore
        theIdealHeight = idealHeight
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading) {
            Text(theTitle)
                .font(.body)
                .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: -5, trailing: 0.0))
            TextEditor(text: $theUserInput)
                .frame(minWidth: 100, idealWidth: 10000, maxWidth: 10000, minHeight: 70, idealHeight: theIdealHeight, maxHeight: 10000, alignment: .leading) // Settings to avoid shrinking edit box to 0 when keyboard appears
                .multilineTextAlignment(.leading)
                .overlay( // Round the edit boundry frame
                         RoundedRectangle(cornerRadius: 5)
                           .stroke(Color.gray, lineWidth: 1)
                )
        }
    }
}

