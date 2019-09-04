//
//  EditSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit

class EditSightViewController: UIViewController, DatabaseListener {
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    
    @IBOutlet weak var sightNameTextField: UITextField!
    @IBOutlet weak var sightDescTextField: UITextField!
    @IBOutlet weak var sightTypeSegment: UISegmentedControl!
    @IBOutlet weak var sightLatitudeTextField: UITextField!
    @IBOutlet weak var sightLongitudeTextField: UITextField!
    @IBOutlet weak var sightPhoto: UIImageView!
    
    var editingSight: Sight?
    var editedSight: Sight?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.sightNameTextField.text = editingSight?.sightName
        self.sightDescTextField.text = editingSight?.sightDesc
        self.sightTypeSegment.selectedSegmentIndex = sightTypeIndex()
        self.sightLatitudeTextField.text = String(format: "%f", editingSight!.sightLatitude)
        self.sightLongitudeTextField.text = String(format: "%f", editingSight!.sightLongitude)
//        self.sightPhoto.image = loadImageData(fileName: editingSight!.sightPhotoFileName!)
        
    }
    

    @IBAction func undoTheEdit(_ sender: Any) {
    }
    @IBAction func takePhotoButton(_ sender: Any) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//        editedSight?.sightName = self.sightNameTextField.text
        print("start on prepare data")
    }
 
    
    func sightTypeIndex() -> Int {
        switch editingSight?.sightType {
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
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }

}
