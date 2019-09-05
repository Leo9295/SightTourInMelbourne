//
//  EditSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit

class EditSightViewController: UIViewController, DatabaseListener, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    
    @IBOutlet weak var sightNameTextField: UITextField!
    @IBOutlet weak var sightDescTextField: UITextField!
    @IBOutlet weak var sightTypeSegment: UISegmentedControl!
    @IBOutlet weak var sightPhoto: UIImageView!
    
    var editingSight: Sight?
    var editedSight: Sight?
    var sightImage: UIImage?

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
        self.sightTypeSegment.selectedSegmentIndex = sightTypeIndex(type: editingSight!.sightType!)
        self.sightPhoto.image = loadImageData(fileName: editingSight!.sightPhotoFileName!)
        
    }

    @IBAction func undoTheEdit(_ sender: Any) {
        self.sightNameTextField.text = editingSight?.sightName
        self.sightDescTextField.text = editingSight?.sightDesc
        self.sightTypeSegment.selectedSegmentIndex = sightTypeIndex(type: editingSight!.sightType!)
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
            self.sightImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        editedSight?.sightName = self.sightNameTextField.text
        
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
