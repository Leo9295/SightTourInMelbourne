//
//  PhotoOfSight+CoreDataProperties.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoOfSight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoOfSight> {
        return NSFetchRequest<PhotoOfSight>(entityName: "PhotoOfSight")
    }

    @NSManaged public var filenameOfPhoto: String?
    @NSManaged public var belongToSight: Sight?

}
