//
//  TripEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/15/22.
//

import Foundation
import CoreData
import CryptoKit

extension TripEntity: Comparable {
    
    // MARK: Accessors
    public var wrappedTitle: String {
        get { title ?? "Unknown Title wdh" }
        set { title = newValue } // by default the value passed into 'set' is named newValue
    }
    public var wrappedDesc: String {
        get { desc ?? "" }
        set { desc = newValue }
    }
    public var wrappedStartTime: Date {
        get { startTime ?? Date() }
        set { startTime = newValue }
    }
    public var wrappedEndTime: Date {
        get {
            if endTime == nil {
                MyLog.debug("wdh *** ERROR *** This should NEVER happen - wrappedEndTime called for nil endTime")
                return Date()
            }
            return endTime!
        }
        set { endTime = newValue }
    }
    
    
    // MARK: Static Funcs
    public static func < (lhs: TripEntity, rhs: TripEntity) -> Bool {
        if (lhs.startTime == nil) {return false}
        if (rhs.startTime == nil) {return false}
        return lhs.startTime! < rhs.startTime!
    }
    
    // Get array of all TripEntities (could be an empty array)
    public static func getAllTripEntities() -> [TripEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        let sortDesc = NSSortDescriptor(key: "startTime", ascending: true)
        request.sortDescriptors = [sortDesc]
        
        // Get array of sorted results
        do {
            let results = try viewContext.fetch(request)
            return results
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error loading TripEnties in getAllTripEntities() \(nsError.userInfo)")
        }
        
        // If we got this far then we had an error getting the TripEntity array so return an empty array
        return []
    }
    
    
        
    // Create a new TripEntity, save it and return it
    // Every field will be filled with a non-nil value except startTime and endTime
    @discardableResult public static func createTripEntity() -> TripEntity {
        let viewContext = PersistenceController.shared.container.viewContext
        let newTrip = TripEntity(context: viewContext)
        newTrip.id = ID_GeneratorEntity.getNextID()
        MyLog.debug("createTripEntity id=\(newTrip.id)")
        newTrip.uuid = UUID()
        newTrip.desc = ""
        newTrip.dotColorRed = 0.0
        newTrip.dotColorBlue = 0.0
        newTrip.dotColorGreen = 1.0
        newTrip.dotColorAlpha = 1.0
        newTrip.dotSize = 3.0
        newTrip.startTime = Date()
        newTrip.endTime = nil
        
        // use createion date as the default title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        newTrip.title = dateFormatter.string(from: Date())
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error creating TripEntity in createTripEntity() \(nsError.userInfo)")
        }
        return newTrip
    }
    
    // Delete a TripEntity object
    static func deleteTripEntity(_ theTripEntity: TripEntity) {
        let viewContext = PersistenceController.shared.container.viewContext
        viewContext.delete(theTripEntity)
    }
    
    // MARK: Member Functions
    
    func save() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error saving TripEntity in call to member func 'save()' \(nsError.userInfo)")
        }
    }
    
}
