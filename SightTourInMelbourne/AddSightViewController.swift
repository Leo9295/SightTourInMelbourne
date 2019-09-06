//
//  AddSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit
import MapKit

class AddSightViewController: UIViewController, DatabaseListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    
    // Map center point
    let center = LocationAnnotation(newTitle: "", newSubTitle: "", latitude: -37.8150783, longitude: 144.9636478)
    
    @IBOutlet weak var sightNameTextField: UITextField!
    @IBOutlet weak var sightDescTextField: UITextField!
    @IBOutlet weak var sightTypeSegment: UISegmentedControl!
    @IBOutlet weak var sightPhotoImage: UIImageView!
    @IBOutlet weak var detailMapView: MKMapView!
    
    var newSightLatitude: Double?
    var newSightLongitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureReconizer:)))
        gestureRecognizer.delegate = self
        detailMapView.addGestureRecognizer(gestureRecognizer)

        self.foucsOn(annotation: center)
        
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        // Leave it blank
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.sightTypeSegment.selectedSegmentIndex = 4
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
        self.detailMapView.removeAnnotations(self.detailMapView.annotations)
        self.foucsOn(annotation: center)
    }
    
    @IBAction func choosePhotoButton(_ sender: Any) {
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
    
    @IBAction func saveNewSight(_ sender: Any) {
        if self.sightNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            displayAlertMessage("The name of Sight must not be empty!", "Input Error")
            self.sightNameTextField.text = ""
            self.sightNameTextField.attributedPlaceholder = NSAttributedString(string: "Input Name of New sight here...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        } else if self.sightDescTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            displayAlertMessage("The short descrption of Sight must not be empty!", "Input Error")
            self.sightDescTextField.text = ""
            self.sightDescTextField.attributedPlaceholder = NSAttributedString(string: "Input Short Descrption of New sight here...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        } else if self.newSightLatitude == nil || self.newSightLongitude  == nil {
            displayAlertMessage("The location of Sight must be set on the map!", "Input Error")
        } else {
            databaseController?.addSight(sightName: sightNameTextField!.text!, sightDesc: sightDescTextField!.text!, latitude: newSightLatitude!, longitude: newSightLongitude!, sightType: sightTypeName(index: sightTypeSegment.selectedSegmentIndex), image: sightPhotoImage.image!)
            dismiss(animated: true, completion: nil)
        }
    }
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
    }
    
    func displayAlertMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func foucsOn(annotation: MKAnnotation){
        detailMapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 700, longitudinalMeters: 700)
        detailMapView.setRegion(detailMapView.regionThatFits(zoomRegion), animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.sightPhotoImage.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
        
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
        // For test
        print("lat: \(coordinate.latitude)")
        print("long: \(coordinate.longitude)")
        self.newSightLatitude = coordinate.latitude
        self.newSightLongitude = coordinate.longitude
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        detailMapView.addAnnotation(myAnnotation)
    }
    
}
