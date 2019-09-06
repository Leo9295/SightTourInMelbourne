//
//  AddSightViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit

class AddSightViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var sightNameTextField: UITextField!
    @IBOutlet weak var sightDescTextField: UITextField!
    @IBOutlet weak var sightTypeSegment: UISegmentedControl!
    @IBOutlet weak var sightPhotoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func clearInput(_ sender: Any) {
        self.sightNameTextField.text = ""
        self.sightDescTextField.text = ""
        self.sightTypeSegment.selectedSegmentIndex = 4
        self.sightPhotoImage.image = UIImage(named: "newPhotoPlaceHolder")
    }
    @IBAction func saveInput(_ sender: Any) {
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
