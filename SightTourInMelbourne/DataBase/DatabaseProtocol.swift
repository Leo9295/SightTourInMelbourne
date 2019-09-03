//
//  DatabaseProtocol.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 3/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case type
    case sights
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTypeChange(change: DatabaseChange, typeSights: [Sight])
    func onSightListChange(change: DatabaseChange, sights: [Sight])
}

protocol DatabaseProtocol: AnyObject {
    var defaultType: Type {get}
    
//    func addSight(newSight: Sight) -> Sight
    func addSight(sightName: String, sightDesc: String, longitude: Double, latitude: Double) -> Sight
    func deleteSight(delSight: Sight)
    func updateSight(updateSight: Sight) -> Sight
    func addType(typeName: String) -> Type
    
    func addSightToType(sight: Sight, type: Type)
    func removeSightFromType(sight: Sight, type: Type)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
