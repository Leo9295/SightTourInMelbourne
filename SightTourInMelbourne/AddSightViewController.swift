//
//  AddSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import MapKit

class AddSightViewController: UIViewController, DatabaseListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    
    @IBOutlet weak var sightNameTextField: UITextField!
    @IBOutlet weak var sightDescTextField: UITextField!
    @IBOutlet weak var sightTypeSegment: UISegmentedControl!
    @IBOutlet weak var sightPhotoImage: UIImageView!
    @IBOutlet weak var detailMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let center = LocationAnnotation(newTitle: "", newSubTitle: "", latitude: -37.8150783, longitude: 144.9636478)
        self.foucsOn(annotation: center)
        
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    

    @IBAction func clearInput(_ sender: Any) {
        self.sightNameTextField.text = ""
        self.sightDescTextField.text = ""
        self.sightTypeSegment.selectedSegmentIndex = 4
        self.sightPhotoImage.image = UIImage(named: "newPhotoPlaceHolder")
    }

    @IBAction func takePicture(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
     }
    
    
    func foucsOn(annotation: MKAnnotation){
        detailMapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
        detailMapView.setRegion(detailMapView.regionThatFits(zoomRegion), animated: true)
    }
}
