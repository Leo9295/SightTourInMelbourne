//
//  Type+CoreDataProperties.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 3/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//
//

import Foundation
import CoreData


extension Type {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Type> {
        return NSFetchRequest<Type>(entityName: "Type")
    }

    @NSManaged public var typeName: String?
    @NSManaged public var containWith: NSSet?

}

// MARK: Generated accessors for containWith
extension Type {

    @objc(addContainWithObject:)
    @NSManaged public func addToContainWith(_ value: Sight)

    @objc(removeContainWithObject:)
    @NSManaged public func removeFromContainWith(_ value: Sight)

    @objc(addContainWith:)
    @NSManaged public func addToContainWith(_ values: NSSet)

    @objc(removeContainWith:)
    @NSManaged public func removeFromContainWith(_ values: NSSet)

}
