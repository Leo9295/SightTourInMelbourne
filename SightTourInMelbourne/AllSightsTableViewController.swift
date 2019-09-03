//
//  AllSightsTableViewController.swift
//  SightTourInMelbourne
//
//  Created by Leo Mingzhe on 4/9/19.
//  Copyright © 2019 Leo Mingzhe. All rights reserved.
//

import UIKit

class AllSightsTableViewController: UITableViewController, DatabaseListener {
    
    var currentSightList: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sights

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onPhotoChange(change: DatabaseChange, photo: PhotoOfSight) {
        // Leave it Blank
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        currentSightList = sights
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentSightList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SightViewCell", for: indexPath) as! SightTableViewCell
        
        cell.sightNameLabel.text = currentSightList[indexPath.row].sightName
        cell.sightDescLabel.text = currentSightList[indexPath.row].sightDesc
        switch currentSightList[indexPath.row].sightType {
        case "Museum":
            cell.sightIconImage.image = UIImage(named: "museum")
        case "Architecture":
            cell.sightIconImage.image = UIImage(named: "architecture")
        case "Art":
            cell.sightIconImage.image = UIImage(named: "art")
        case "Histroy":
            cell.sightIconImage.image = UIImage(named: "history")
        default:
            cell.sightIconImage.image = UIImage(named: "other")
        }
//        cell.sightNameLabel.text = currentSightList[indexPath.row].sightName
//        cell.sightDescLabel.text = currentSightList[indexPath.row].sightDesc

        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseAlertView(indexPath: indexPath)
    }
    
    // Cited from: https://www.jianshu.com/p/2374436d565c
    func chooseAlertView(indexPath: IndexPath){
        let alertController = UIAlertController(title: "Any Options?", message: "", preferredStyle: UIAlertController.Style.alert)
        let showOnMapAction = UIAlertAction(title: "Show On Map", style: UIAlertAction.Style.default) {
            (_) in
            self.jumpToMap(indexPath: indexPath)
            
        }
        let showDetailAction = UIAlertAction(title: "Show Details", style: UIAlertAction.Style.default) {
            (_) in
            self.showCurrentRowDetail(indexPath: indexPath)
            
        }
        alertController.addAction(showOnMapAction)
        alertController.addAction(showDetailAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func jumpToMap(indexPath: IndexPath) {
//        self.tableView!.deselectRow(at: indexPath, animated: true)
//        let selectedSight = self.currentSightList[indexPath.row]
//
//        self.performSegue(withIdentifier: "ViewListSegue", sender: selectedSight)
    }
    
    func showCurrentRowDetail(indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
        let selectedSight = self.currentSightList[indexPath.row]
        
        self.performSegue(withIdentifier: "ShowDetailView", sender: selectedSight)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
