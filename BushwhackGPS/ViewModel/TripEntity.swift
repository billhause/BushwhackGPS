//
//  TripEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 3/15/22.
//

import Foundation
import CoreData
import CryptoKit
import SwiftUI // Color

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
//        get { startTime ?? Date() }
        get {
            if startTime == nil {
                MyLog.debug("wdh *** ERROR *** This should NEVER happen - wrappedStartTime called for nil endTime")
                return Date()
            }
            return startTime!
        }
        set {
            startTime = newValue
            MyLog.debug("wrappedStartTime set called for TripEntity \(newValue)")
        }
    }
    public var wrappedEndTime: Date {
        get {
            if endTime == nil {
                return Date()
            }
            return endTime!
        }
        set {
            endTime = newValue
            MyLog.debug("wrappedEndTime set called for TripEntity \(newValue)")
        }
    }

    public var dotColor: Color {
        get {
            return Color(.sRGB,
                  red: dotColorRed,
                  green: dotColorGreen,
                  blue: dotColorBlue)
        }
        set {
            var rgbRed: CGFloat = 0
            var rgbGreen: CGFloat = 0
            var rgbBlue: CGFloat = 0
            var rgbAlpha: CGFloat = 0
            let myUIColor = UIColor(newValue)
            myUIColor.getRed(&rgbRed, green: &rgbGreen, blue: &rgbBlue, alpha: &rgbAlpha)
            dotColorRed = rgbRed
            dotColorBlue = rgbBlue
            dotColorGreen = rgbGreen
            dotColorAlpha = rgbAlpha // should always be 1.0 for display on map
            
            let debugString = String(format: "* TripEntity Colors red:%.2f green:%.2f blue:%.2f", rgbRed, rgbGreen, rgbBlue)

            MyLog.debug(debugString)
        }
        
    }

    public var dotUIColor: UIColor {
        get {
            UIColor(red: dotColorRed, green: dotColorGreen, blue: dotColorBlue, alpha: dotColorAlpha)
        }
    }
    
    // MARK: Static Funcs
    public static func < (lhs: TripEntity, rhs: TripEntity) -> Bool {
        if (lhs.startTime == nil) {return false}
        if (rhs.startTime == nil) {return false}
        return lhs.startTime! < rhs.startTime!
    }
    
    // Get array of all TripEntities (could be an empty array)
    public static func getAllTripEntities_NewestToOldest() -> [TripEntity] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<TripEntity>(entityName: "TripEntity")
        let sortDesc = NSSortDescriptor(key: "startTime", ascending: false) // Sort Newest to Oldest
        request.sortDescriptors = [sortDesc]
        
        // Get array of sorted results
        do {
            let results = try viewContext.fetch(request)
            return results
        } catch {
            let nsError = error as NSError
            MyLog.debug("wdh Error loading TripEnties in getAllTripEntities_NewestToOldest() \(nsError.userInfo)")
        }
        
        // If we got this far then we had an error getting the TripEntity array so return an empty array
        return []
    }
    
    // Return the TripEntity that should be used for the specified Date
    // Ignore Trips that have showTripDots == false
    // If more than one TripEntity contain the specified date, return the one with the latest start date
    // Return nil if there is no TripEntity that includes the specified Date
    public static func getTripEntityForDate(theDate: Date) -> TripEntity? {
        // the list will come back newest to oldest
        let theTripEntities = getAllTripEntities_NewestToOldest()
        for theTripEntity in theTripEntities {
//            MyLog.debug("TripEntity '\(theTripEntity.title)' Start Date: \(theTripEntity.startTime)")
            if theTripEntity.showTripDots == false {
                continue 
            }
            if theTripEntity.startTime == nil {
                MyLog.debug("ERROR - WHY DOES THIS TripEntity have no startTime? This Should Not Happen")
                continue // skip this entity
            } else { // start time not nil
                if theTripEntity.startTime! > theDate {
                    continue // The Date is not in theTripEntity's date range
                } else { // check end time
                    // Start time is good, now check end time
                    if theTripEntity.endTime == nil {
                        // nil end time means there is no end time so this is the entity to return
                        return theTripEntity
                    } else { // end Time not nil
                        if theTripEntity.endTime! > theDate {
                            // The date is in the range so This is the TripEntity to return
                            return theTripEntity
                        }
                    } // end time not nil
                } // check end time
            } // start time not nil
        } // Loop through TripEntities
        
        // If we got this far then there are not any TripEntities for this date so return nil
        return nil
    }

        
    // Create a new TripEntity, save it and return it
    // Every field will be filled with a non-nil value except startTime and endTime
    @discardableResult public static func createTripEntity(dotSize: Double) -> TripEntity {
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
        newTrip.dotSize = dotSize
        newTrip.startTime = Date()
        newTrip.endTime = nil
        newTrip.showTripDots = true
        
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
