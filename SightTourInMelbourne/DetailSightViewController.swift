//
//  DetailSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailSightViewController: UIViewController {
    
    @IBOutlet weak var sightNameLabel: UILabel!
    @IBOutlet weak var sightDescLabel: UILabel!
    @IBOutlet weak var sightTypeLabel: UILabel!
    @IBOutlet weak var detailMapView: MKMapView!
    
    var selectedSight: Sight?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sightNameLabel.text = selectedSight?.sightName
        self.sightDescLabel.text = selectedSight?.sightDesc
        self.sightTypeLabel.text = selectedSight?.sightType
        let location = LocationAnnotation(newTitle: selectedSight!.sightName!, newSubTitle: "", latitude: selectedSight!.sightLatitude, longitude: selectedSight!.sightLongitude)
        foucsOn(annotation: location)
        detailMapView.addAnnotation(location)
//        let address = convertLatAndLonToAddress(lat: selectedSight!.sightLatitude, lon: selectedSight!.sightLongitude)
//        self.sightAddressLabel.text = address
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func save(_ unwindSegue: UIStoryboardSegue) {
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        if segue.identifier == "EditDetailSegue" {
//            let controller = segue.destination as! EditSightViewController
//            controller.editingSight = sender as? Sight
//        }
        if let navigationController = segue.destination as? UINavigationController {
            let editSightViewController = navigationController.viewControllers.first as? EditSightViewController
            editSightViewController?.editingSight = selectedSight
        }
    }
    
    func foucsOn(annotation: MKAnnotation){
        detailMapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        detailMapView.setRegion(detailMapView.regionThatFits(zoomRegion), animated: true)
    }
    
//    func convertLatAndLonToAddress(lat: Double, lon: Double) -> String {
//        var address: String = ""
//        let geoCoder = CLGeocoder()
//        let location = CLLocation(latitude: lat, longitude: lon)
//        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//            var placeMark: CLPlacemark!
//            placeMark = placemarks?[0]
//
//            if let street = placeMark.thoroughfare {
//                print(street)
//                address = street
//            }
//        })
//        return address
//    }

}
