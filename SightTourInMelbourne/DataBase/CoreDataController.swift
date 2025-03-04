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
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?

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
    
    func addSight(sightName: String, sightDesc: String, latitude: Double, longitude: Double, sightType: String, image: UIImage) {
        
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        }
        
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into: persistantContainer.viewContext) as! Sight
        sight.sightName = sightName
        sight.sightDesc = sightDesc
        sight.sightLatitude = latitude
        sight.sightLongitude = longitude
        sight.sightType = sightType
        sight.sightPhotoFileName =  "\(date)"
        saveContext()
    }
    
    func deleteSight(delSight: Sight) {
        persistantContainer.viewContext.delete(delSight)
        saveContext()
    }
    
//    // Cited from: http://stackoverflow.com/questions/26345189/how-to-update-a-coredata-entry-that-has-already-been-saved-in-swift
//    func updateSight(updateSight: Sight) {
//        let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "sightName = %@", (updateSight.sightName)!)
//
//        do{
//            let results = try persistantContainer.viewContext.fetch(fetchRequest)
//            if results.count != 0 {
//                results[0].setValue(updateSight.sightName, forKey: "sightName")
//                results[0].setValue(updateSight.sightDesc, forKey: "sigthDesc")
//                results[0].setValue(updateSight.sightType, forKey: "sightType")
//                results[0].setValue(updateSight.sightLatitude, forKey: "sightLatitude")
//                results[0].setValue(updateSight.sightLongitude, forKey: "sightLongitude")
//                results[0].setValue(updateSight.sightPhotoFileName, forKey: "sightPhotoFileName")
//            }
//        } catch {
//            print("Update Sight information failed: \(error)")
//        }
//        saveContext()
//    }
//
    // Cited from: https://medium.com/@ankurvekariya/core-data-crud-with-swift-4-2-for-beginners-40efe4e7d1cc
    func fetchSightWithName(fetchedSightName: String) -> Sight? {
        let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "sightName = %@", fetchedSightName)
        
        do {
            let results = try persistantContainer.viewContext.fetch(fetchRequest)
            if results.count != 0 {
                return results[0]
            } else {
                return nil
            }
        } catch {
            print("Searching Sight failed: \(error)")
        }
        return nil
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.sight || listener.listenerType == ListenerType.all {
            listener.onSightListChange(change: .update, sights: fetchAllSights())
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
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allSightsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.sight || listener.listenerType == ListenerType.all {
                    listener.onSightListChange(change: .update, sights: fetchAllSights())
                }
            }
        } 
    }
    
    func createDefaultSight(sightName: String, sightDesc: String, latitude: Double, longitude: Double, sightType: String, imageName: String) {

        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into: persistantContainer.viewContext) as! Sight
        sight.sightName = sightName
        sight.sightDesc = sightDesc
        sight.sightLatitude = latitude
        sight.sightLongitude = longitude
        sight.sightType = sightType
        sight.sightPhotoFileName = imageName
        saveContext()
    }
    
    // MARK: - Default entries
    func createDefaultEntries() {
        // Sight 1
        let _ = createDefaultSight(sightName: "Victoria Police Museum", sightDesc: "From the largest collection of Kelly Gang armour in Australia to forensic evidence from some of Melbourne's most notorious crimes, the Victoria Police Museum presents visitors with an intriguing insight into the social history of policing and crime.", latitude: -37.822077, longitude: 144.9508159, sightType: "Museum", imageName: "Victoria_Police_Museum")

        // Sight 2
        let _ = createDefaultSight(sightName: "Chinese Museum",sightDesc: "Located in the heart of Melbourne’s Chinatown, the Chinese Museum (Museum of Chinese Australian History)’s five floors showcase the heritage and culture of Australia’s Chinese community.",latitude: -37.8107583, longitude: 144.9669754, sightType: "Museum", imageName: "Chinese_Museum")

        // Sight 3
        let _ = createDefaultSight(sightName: "Her Majesty's Theatre",sightDesc: "Newly restored and with ongoing renovations and improvements - including new and more comfortable seats throughout the auditorium, a modern stage house, enlarged orchestra pit and upgraded backstage facilities - Her Majesty's Theatre continues to be a truly dynamic venue, hosting musicals, plays, opera, dance, comedy and more. Its Art Deco interior boasts an impressive seating capacity of 1700 seats, yet the auditorium is renowned for its intimate setting.",latitude: -37.8109548,longitude: 144.9685306, sightType: "Other", imageName: "Her_Majesty's_Theatre")

        // Sight 4
        let _ = createDefaultSight(sightName: "Melbourne Museum",sightDesc: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria. It shows you Victoria's intriguing permanent collections and bring you brilliant temporary exhibitions from near and far. You'll see Victoria's natural environment, cultures and history through different perspectives.",latitude: -37.803273,longitude: 144.9695468, sightType: "Museum", imageName: "Melbourne_Museum")

        // Sight 5
        let _ = createDefaultSight(sightName: "National Sports Museum at the MCG",sightDesc: "The MCG recognises and celebrates its heritage and sporting history with a commitment seen at very few stadiums anywhere in the world by housing the National Sports Museum. Across a multitude of sports, the museum features memorabilia from some of the country's biggest heroes and highlights moments that have shaped the traditions of Australian sport.",latitude: -37.8189029,longitude: 144.9815027, sightType: "Museum", imageName: "National_Sports_Museum")

        // Sight 6
        let _ = createDefaultSight(sightName: "Public Record Office Victoria",sightDesc: "Public Record Office Victoria holds a vast array of records created by Victorian Government departments and authorities including the State's courts, local councils, schools, public hospitals and other public offices.",latitude: -37.7969229,longitude: 144.9397204, sightType: "Museum", imageName: "Public_Record_Office_Victoria")

        // Sight 7
        let _ = createDefaultSight(sightName: "Fire Services Museum of Victoria",sightDesc: "The Fire Services Museum of Victoria is an organisation dedicated to the preservation and showcasing of fire-fighting memorabilia from Victoria, Australia and overseas.",latitude: -37.8085417,longitude: 144.9732168, sightType: "Museum", imageName: "Fire_Services_Museum_of_Victoria")


        // Sight 8
        let _ = createDefaultSight(sightName: "Melbourne Steam Traction Engine Club",sightDesc: "The Melbourne Steam Traction Engine Club operates a vintage engine museum set in six hectares of parkland in the south eastern suburb of Scoresby. In all, there are several hundred engines and related exhibits housed in a number of exhibition sheds around the grounds.",latitude: -37.905392,longitude: 145.2120818, sightType: "Museum", imageName: "Melbourne_Steam_Traction_Engine_Club")


        // Sight 9
        let _ = createDefaultSight(sightName: "Portable Iron Houses",sightDesc: "The nineteenth century Portable Iron Houses provide an insight into life in Emerald Hill, now known as South Melbourne, during the gold rush years. These remarkable examples of early property development are among the few prefabricated iron buildings remaining in the world.",latitude: -37.8340349,longitude: 144.9510848, sightType: "Architecture", imageName: "Portable_Iron_Houses")


        // Sight 10
        let _ = createDefaultSight(sightName: "Shrine of Remembrance",sightDesc: "The Shrine of Remembrance is a building with a soul. Opened in 1934, the Shrine is the Victorian state memorial to Australians who served in global conflicts throughout our nation’s history. Inspired by Classical architecture, the Shrine was designed and built by veterans of the First World War.",latitude: -37.8305164,longitude: 144.9712379, sightType: "Architecture", imageName: "Shrine_of_Remembrance")


        // Sight 11
        let _ = createDefaultSight(sightName: "Heide Museum of Modern Art",sightDesc: "Heide Museum of Modern Art, or Heide as it is affectionately known, began life in 1934 as the Melbourne home of John and Sunday Reed and has since evolved into one of Australia's most unique destinations for modern and contemporary Australian art. Located just twenty minutes from the city, Heide boasts fifteen acres of beautiful gardens, three dedicated exhibition spaces, two historic kitchen gardens, a sculpture park and the Heide Store.",latitude: -37.7581745,longitude: 145.0809813, sightType: "Art", imageName: "Heide_Museum")


        // Sight 12
        let _ = createDefaultSight(sightName: "Steamrail Victoria",sightDesc: "Steamrail Victoria is a non-profit organisation dedicated to the restoration and operation of vintage steam, diesel and electric locomotives and carriages. The Vintage Train operates monthly to destinations throughout the state. It travels all over the Victorian Railways broad gauge network offering a variety of tours for all tastes, including weekend excursions to interesting and popular destinations.",latitude: -37.8504231,longitude: 144.8781923, sightType: "Histroy", imageName: "Steamrail_Victoria")


        // Sight 13
        let _ = createDefaultSight(sightName: "St Michael's Uniting Church",sightDesc: "St Michael's is a unique church in the heart of the city. It is not only unique for its relevant, contemporary preaching, but for its unusual architecture. St Michael's strives to be the best possible model of what the New Faith can be; they want to attract and sustain larger numbers of people who see that this expression of church life is the most meaningful and worthwhile experience for them.",latitude: -37.8143091,longitude: 144.9670763, sightType: "Histroy", imageName: "St_Michael's_Uniting_Church")


        // Sight 14
        let _ = createDefaultSight(sightName: "Old Melbourne Gaol",sightDesc: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol. Shrouded in secrets, wander the same cells and halls as some of history’s most notorious criminals, from Ned Kelly to Squizzy Taylor, and discover the stories that never left. Hosting day and night tours, exclusive events and kids activities throughout school holidays and an immersive lock-up experience in the infamous City Watch House, the Gaol remains Melbourne’s most spell-binding journey into its past.",latitude: -37.807832,longitude: 144.9631231, sightType: "Histroy", imageName: "Old_Melbourne_Gaol")


        // Sight 15
        let _ = createDefaultSight(sightName: "Manchester Unity Building",sightDesc: "The Manchester Unity Building is one of Melbourne's most iconic Art Deco landmarks. It was built in 1932 for the Manchester Unity Independent Order of Odd Fellows (IOOF), a friendly society providing sickness and funeral insurance. Melbourne architect Marcus Barlow took inspiration from the 1927 Chicago Tribune Building. His design incorporated a striking New Gothic style façade of faience tiles with ground-floor arcade and mezzanine shops, café and rooftop garden. Step into the arcade for a glimpse of the marble interior, beautiful friezes and restored lift – or book a tour for a peek upstairs.",latitude: -37.8153866,longitude: 144.9641383, sightType: "Architecture", imageName: "Manchester_Unity_Building")

    }
    
}
