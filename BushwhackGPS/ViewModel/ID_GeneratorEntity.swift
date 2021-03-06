//
//  ID_GeneratorEntity.swift
//  BushwhackGPS
//
//  Created by William Hause on 1/13/22.
//

import Foundation
import CoreData


extension ID_GeneratorEntity: Comparable {

    public static func < (lhs: ID_GeneratorEntity, rhs: ID_GeneratorEntity) -> Bool {
        // This doesn't need to be comparable but what the heck...
        lhs.nextIDToReturn < rhs.nextIDToReturn
    }

    // Get the One and Only ID_GeneratorEntity or create on if it doesn't exist yet
    private static func getID_GeneratorEntity() -> ID_GeneratorEntity {
        let context = PersistenceController.shared.container.viewContext
        
        let request = NSFetchRequest<ID_GeneratorEntity>(entityName: "ID_GeneratorEntity")
        
        // SortDescriptor and Predicate are not needed since I'm retriveing the one and only record and not filtering the results
        //request.predicate = NSPredicate(format: "score > %@ AND score <%@", NSNumber(value: 3), NSNumber(value: 100))
        //let sortDesc = NSSortDescriptor(key: "score", ascending: true)
        //request.sortDescriptors = [sortDesc] // array of sort descriptors to use

        // Get array of results
        let results = try? context.fetch(request) // Should never fail
        
        // If we found one, return it.  Otherwise create one, save it and return it
        if let theID_GeneratorEntity = results!.first {
            // Found one so return it
            return theID_GeneratorEntity
        } else {
            // None found so create one, save it and return it
            let theID_GeneratorEntity = ID_GeneratorEntity(context: context)
            theID_GeneratorEntity.nextIDToReturn = 1 // Start numbering at 1
            
            try? context.save() // Not handling the try/catch because there's nothing I can do about it
            return theID_GeneratorEntity
        }
    }
    
    // MARK: Intents
    
    // Get the Next ID and increment it
    // Don't need to save the updated ID number because it will
    // save the next time a CoreData object gets saved.
    public static func getNextID() -> Int64 {
        // Return the next ID and increment. Then save next value in core data
        let theIDGenerator = getID_GeneratorEntity()
        let theNextID = theIDGenerator.nextIDToReturn
        theIDGenerator.nextIDToReturn += 1
        
        return theNextID
    }
    
    // Show the next ID WITHOUT incrementing it
    public static func peekNextID() -> Int64 {
        let theIDGenerator = getID_GeneratorEntity()
        let theNextID = theIDGenerator.nextIDToReturn
        return theNextID
    }
    
}

