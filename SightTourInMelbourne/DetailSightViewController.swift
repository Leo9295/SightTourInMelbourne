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

class DetailSightViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.sight
    
    @IBOutlet weak var sightNameLabel: UILabel!
    @IBOutlet weak var sightDescLabel: UILabel!
    @IBOutlet weak var sightTypeLabel: UILabel!
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var sightTypeImageView: UIImageView!
    @IBOutlet weak var sightPhotoImageView: UIImageView!
    
    weak var databaseController: DatabaseProtocol?
    var selectedSight: Sight?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        // Leave it Blank
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.sightPhotoImageView.image = loadImageData(fileName: selectedSight!.sightPhotoFileName!)
        self.sightNameLabel.text = selectedSight?.sightName
        self.sightDescLabel.text = selectedSight?.sightDesc
        self.sightTypeLabel.text = selectedSight?.sightType
        let location = LocationAnnotation(newTitle: selectedSight!.sightName!, newSubTitle: "", latitude: selectedSight!.sightLatitude, longitude: selectedSight!.sightLongitude)
        foucsOn(annotation: location)
        switch selectedSight?.sightType {
        case "Museum":
            sightTypeImageView.image = UIImage(named: "museum")
        case "Architecture":
            sightTypeImageView.image = UIImage(named: "architecture")
        case "Art":
            sightTypeImageView.image = UIImage(named: "art")
        case "Histroy":
            sightTypeImageView.image = UIImage(named: "history")
        default:
            sightTypeImageView.image = UIImage(named: "other")
        }
        detailMapView.addAnnotation(location)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func save(_ unwindSegue: UIStoryboardSegue) {
        if let editSightViewChontroller = unwindSegue.source as? EditSightViewController {
            databaseController?.deleteSight(delSight: selectedSight!)
            databaseController?.addSight(sightName: editSightViewChontroller.editedSightName!, sightDesc: editSightViewChontroller.editedSightDesc!, latitude: editSightViewChontroller.editedSightLatitude!, longitude: editSightViewChontroller.editedSightLongitude!, sightType: editSightViewChontroller.editedSightType!, image: editSightViewChontroller.editedSightImage!)
            self.selectedSight = databaseController?.fetchSightWithName(fetchedSightName: editSightViewChontroller.editedSightName!)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let navigationController = segue.destination as? UINavigationController {
            let editSightViewController = navigationController.viewControllers.first as? EditSightViewController
            editSightViewController?.editingSight = selectedSight
        }
    }
    
    func displayAlertMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func foucsOn(annotation: MKAnnotation){
        detailMapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
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

}
