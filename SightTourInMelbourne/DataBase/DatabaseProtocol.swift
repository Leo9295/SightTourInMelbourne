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
    case photo
    case sights
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onSightListChange(change: DatabaseChange, sights: [Sight])
    func onPhotoChange(change: DatabaseChange, photo: PhotoOfSight)
}

protocol DatabaseProtocol: AnyObject {
    
    func addSight(sightName: String, sightDesc: String, latitude: Double, longitude: Double, sightType: String) -> Sight
    func deleteSight(delSight: Sight)
    func updateSight(updateSight: Sight) -> Sight
    
    func addPhoto(photoName: String)
    
    func addPhotoToSight(sight: Sight, photo: PhotoOfSight)
    func removePhotoFromSight(sight: Sight)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
