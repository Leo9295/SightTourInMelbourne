//
//  Sight+CoreDataProperties.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
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
    @NSManaged public var sightLatitude: Double
    @NSManaged public var sightLongitude: Double
    @NSManaged public var sightPhotoFileName: String?
    @NSManaged public var sightType: String?

}
