//
//  BWViewModel.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/18/22.
//

import Foundation

class Map_ViewModel: ObservableObject {
    @Published private var theMap_Model: Map_Model // Published so that we don't haver to call objectWillChange.send() when the model is updated.
    
    // MARK: Initializers
    init() {
        theMap_Model = Map_Model()
        theMap_Model.isHybrid = false // Start off in standard map mode
    }
    
    // MARK: Flag Variables
    var isHybrid: Bool { // Expose so the view model can modify it indirectly through the ViewModel
        get {
            return theMap_Model.isHybrid
        }
        set(newValue) {
            theMap_Model.isHybrid = newValue
        }
    }
    
    
    
}

