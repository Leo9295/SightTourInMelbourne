//
//  CoreDataController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 3/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    let DEFAULT_TYPES = "Default Types"
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?
    var typeSightsFetchedResultsController: NSFetchedResultsController<Sight>?

    override init() {
        persistantContainer = NSPersistentContainer(name: "SightTourInMelbourne")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
        
        // if there is no data in the database in the beginning (e.g. the first time run the application)
        // create new default sights and types for the application
        if fetchAllSights().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
//    func addSight(newSight: Sight) -> Sight {
//        var sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into: persistantContainer.viewContext) as! Sight
//        sight = newSight
//        saveContext()
//        return sight
//    }
    
    func addSight(sightName: String, sightDesc: String, longitude: Double, latitude: Double) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into: persistantContainer.viewContext) as! Sight
        sight.sightName = sightName
        sight.sightDesc = sightDesc
        sight.latitude = latitude
        sight.longitude = longitude
        saveContext()
        return sight
    }
    
    func deleteSight(delSight: Sight) {
        persistantContainer.viewContext.delete(delSight)
        saveContext()
    }
    
    func updateSight(updateSight: Sight) -> Sight {
        // leave it blank
        let sight: Sight = Sight()
        return sight
    }
    
    func addType(typeName: String) -> Type {
        let type = NSEntityDescription.insertNewObject(forEntityName: "Type", into: persistantContainer.viewContext) as! Type
        type = newType
        saveContext()
        return type
    }
    
    func addSightToType(sight: Sight, type: Type) {
        type.addToContainWith(sight)
        saveContext()
    }
    
    func removeSightFromType(sight: Sight, type: Type) {
        type.removeFromContainWith(sight)
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.sights || listener.listenerType == ListenerType.all {
            listener.onSightListChange(change: .update, sights: fetchAllSights())
        }
        
        if listener.listenerType == ListenerType.type || listener.listenerType == ListenerType.all {
            listener.onTypeChange(change: .update, typeSights: fetchTypeOfSights())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllSights() -> [Sight] {
        if allSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "sightName", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightsFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allSightsFetchedResultsController?.delegate = self
            
            do{
                try allSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sights = [Sight]()
        if allSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (allSightsFetchedResultsController?.fetchedObjects)!
        }
        
        return sights
    }
    
    func fetchTypeOfSights() -> [Sight] {
        if typeSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "typeName", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            let predicate = NSPredicate(format: "ANY containWith.typeName == %@", DEFAULT_TYPES)
            fetchRequest.predicate = predicate
            typeSightsFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            typeSightsFetchedResultsController?.delegate = self
            
            do {
                try typeSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var sights = [Sight]()
        if typeSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (typeSightsFetchedResultsController?.fetchedObjects)!
        }
        
        return sights
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSightsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.sights || listener.listenerType == ListenerType.all {
                    listener.onSightListChange(change: .update, sights: fetchAllSights())
                }
            }
        } else if controller == typeSightsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.type || listener.listenerType == ListenerType.all {
                    listener.onTypeChange(change: .update, typeSights: fetchTypeOfSights())
                }
            }
        }
    }
    
    // MARK: - Default entries
    lazy var defaultType: Type = {
        var types = [Type]()
        
        let request: NSFetchRequest<Type> = Type.fetchRequest()
        let predicate = NSPredicate(format: "typeName = %@", DEFAULT_TYPES)
        request.predicate = predicate
        do {
            try types = persistantContainer.viewContext.fetch(Type.fetchRequest()) as! [Type]
        } catch {
            print("Fetch Request failed: \(error)")
        }
        
        if types.count == 0 {
            var type: Type = Type()
            type.typeName = DEFAULT_TYPES
            return addType(newType: type)
        } else {
            return types.first!
        }
    }()
    
    func createDefaultEntries() {
        // option 1
//        let newSight = Sight()
//        newSight.sightName = "Victoria Police Museum"
//        newSight.sightDesc = "From the largest collection of Kelly Gang armour in Australia to forensic evidence from some of Melbourne's most notorious crimes, the Victoria Police Museum presents visitors with an intriguing insight into the social history of policing and crime."
//        newSight.latitude = -37.822077
//        newSight.longitude = 144.9508159
        
        // option 2
        let _ = addSight(sightName: "Victoria Police Museum", sightDesc: "From the largest collection of Kelly Gang armour in Australia to forensic evidence from some of Melbourne's most notorious crimes, the Victoria Police Museum presents visitors with an intriguing insight into the social history of policing and crime.", longitude: 144.9508159, latitude: -37.822077)
        
//        let _ = addSight(newSight: newSight)
    }
    
    
}
