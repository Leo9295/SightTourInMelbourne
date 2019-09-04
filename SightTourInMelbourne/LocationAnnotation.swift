//
//  LocationAnnotation.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(newTitle: String, newSubTitle: String, latitude: Double, longitude: Double){
        self.title = newTitle
        self.subtitle = newSubTitle
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
