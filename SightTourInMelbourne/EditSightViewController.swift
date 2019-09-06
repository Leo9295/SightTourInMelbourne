//
//  EditSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import MapKit

class EditSightViewController: UIViewController, DatabaseListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    
    @IBOutlet weak var sightNameTextField: UITextField!
    @IBOutlet weak var sightDescTextField: UITextField!
    @IBOutlet weak var sightTypeSegment: UISegmentedControl!
    @IBOutlet weak var sightPhoto: UIImageView!
    @IBOutlet weak var detailMapView: MKMapView!
    
    var editingSight: Sight?
//    editedSightImagevar editedSight: Sight?
    
    var editedSightName: String?
    var editedSightDesc: String?
    var editedSightLatitude: Double?
    var editedSightLongitude: Double?
    var editedSightType: String?
    var editedSightImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureReconizer:)))
        gestureRecognizer.delegate = self
        detailMapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.sightNameTextField.text = editingSight?.sightName
        self.sightDescTextField.text = editingSight?.sightDesc
        self.sightTypeSegment.selectedSegmentIndex = sightTypeIndex(type: editingSight!.sightType!)
        self.sightPhoto.image = loadImageData(fileName: editingSight!.sightPhotoFileName!)
        
        let center = LocationAnnotation(newTitle: "", newSubTitle: "", latitude: -37.8150783, longitude: 144.9636478)
        self.foucsOn(annotation: center)
        
        
    }

    @IBAction func undoTheEdit(_ sender: Any) {
        self.sightNameTextField.text = editingSight?.sightName
        self.sightDescTextField.text = editingSight?.sightDesc
        self.sightTypeSegment.selectedSegmentIndex = sightTypeIndex(type: editingSight!.sightType!)
        self.editedSightImage = self.sightPhoto.image
    }
    
    @IBAction func takePhotoButton(_ sender: Any) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.sightPhoto.image = pickedImage
            self.editedSightImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        self.editedSightName = self.sightNameTextField.text
        self.editedSightDesc = self.sightDescTextField.text
        let type = sightTypeName(index: self.sightTypeSegment.selectedSegmentIndex)
        self.editedSightType = type
    }
 
    
    func sightTypeIndex(type: String) -> Int {
        switch type {
        case "Museum":
            return 0
        case "Architecture":
            return 1
        case "Art":
            return 2
        case "Histroy":
            return 3
        default:
            return 4
        }
    }
    
    func sightTypeName(index: Int) -> String {
        switch index {
        case 0:
            return "Museum"
        case 1:
            return "Architecture"
        case 2:
            return "Art"
        case 3:
            return "Histroy"
        default:
            return "Other"
        }
    }
    
    func foucsOn(annotation: MKAnnotation){
        detailMapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
        detailMapView.setRegion(detailMapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        var image: UIImage?
        if isPurnInt(string: fileName) {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)

            if let pathComponent = url.appendingPathComponent(fileName) {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                let fileData = fileManager.contents(atPath: filePath)
                image = UIImage(data: fileData!)
            }
        } else {
            image = UIImage(named: fileName)
        }
        return image
    }
    
    // Cited from: https://blog.csdn.net/hengyunbin/article/details/85260760
    func isPurnInt(string: String) -> Bool {
        let scan: Scanner = Scanner(string: string)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    // Cited from: https://www.raywenderlich.com/433-uigesturerecognizer-tutorial-getting-started#toc-anchor-007
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        // remove pins on the map (clear the map)
        detailMapView.removeAnnotations(detailMapView.annotations)
        let location = gestureReconizer.location(in: detailMapView)
        let coordinate = detailMapView.convert(location,toCoordinateFrom: detailMapView)
        print("lat: \(coordinate.latitude)")
        print("long: \(coordinate.longitude)")
        self.editedSightLatitude = coordinate.latitude
        self.editedSightLongitude = coordinate.longitude
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        detailMapView.addAnnotation(myAnnotation)
    }

}
