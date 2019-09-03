//
//  Sight+CoreDataProperties.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 3/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//
//

import Foundation
import CoreData


extension Sight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sight> {
        return NSFetchRequest<Sight>(entityName: "Sight")
    }

    @NSManaged public var sightName: String? 
    @NSManaged public var sightDesc: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var photoFile: String?
    @NSManaged public var belongTo: Type?

}
