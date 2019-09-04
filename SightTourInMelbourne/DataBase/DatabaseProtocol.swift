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
    case sight
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onSightListChange(change: DatabaseChange, sights: [Sight])
}

protocol DatabaseProtocol: AnyObject {
    
    func addSight(sightName: String, sightDesc: String, latitude: Double, longitude: Double, sightType: String)
    func deleteSight(delSight: Sight)
    func updateSight(updateSight: Sight)
    func fetchSightWithName(fetchedSightName: String) -> Sight?
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
}
