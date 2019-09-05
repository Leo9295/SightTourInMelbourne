//
//  SightMapViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import MapKit

class SightMapViewController: UIViewController, MKMapViewDelegate, DatabaseListener, FocusSightDelegate{
    
    var currentList: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    

    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Do any additional setup after loading the view.
        foucsOn(annotation: appDelegate.centralLocation)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ViewListSegue" {
            let destination = segue.destination as! AllSightsTableViewController
            destination.focusSightDelegate = self
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        mapView.removeAnnotations(mapView!.annotations)
        for sight in currentList{
            let location = changeSightToAnnotation(sight: sight)
            mapView.addAnnotation(location)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func foucsOn(annotation: MKAnnotation){
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func focusOn(index: Int) {
        let location = changeSightToAnnotation(sight: currentList[index])
        mapView.selectAnnotation(location, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location.coordinate
    }
    */
    
    // 修改地图图标
//    override func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        currentList = sights
    }
    
    func changeSightToAnnotation(sight: Sight) -> LocationAnnotation {
        let location = LocationAnnotation(newTitle: sight.sightName!, newSubTitle: sight.sightType!, latitude: sight.sightLatitude, longitude: sight.sightLongitude)
        return location
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func save(_ unwindSegue: UIStoryboardSegue) {
        
    }

}
