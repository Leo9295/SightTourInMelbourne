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
    var filteredSights: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.sight
    
    weak var focusSightDelegate: FocusSightDelegate?
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Search Bar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Sights"
        navigationItem.searchController = searchController
        definesPresentationContext = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
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
        if isFiltering() {
            return filteredSights.count
        }
        return currentSightList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SightViewCell", for: indexPath) as! SightTableViewCell

        if isFiltering() {
            cell.sightNameLabel.text = filteredSights[indexPath.row].sightName
            cell.sightDescLabel.text = filteredSights[indexPath.row].sightDesc
            switch filteredSights[indexPath.row].sightType {
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
        } else {
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
        }

        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseAlertView(indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            databaseController?.deleteSight(delSight: currentSightList[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
    }
    
    // Cited from: https://www.jianshu.com/p/2374436d565c
    func chooseAlertView(indexPath: IndexPath){
        let alertController = UIAlertController(title: "Any Options?", message: "", preferredStyle: UIAlertController.Style.alert)
        let showOnMapAction = UIAlertAction(title: "Show On Map", style: UIAlertAction.Style.default) {
            (_) in
            self.jumpToMap(index: indexPath.row)
            
        }
        let showDetailAction = UIAlertAction(title: "Show Details", style: UIAlertAction.Style.default) {
            (_) in
            self.showCurrentRowDetail(indexPath: indexPath)
            
        }
        alertController.addAction(showOnMapAction)
        alertController.addAction(showDetailAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func jumpToMap(index: Int) {
        focusSightDelegate?.focusOn(index: index)
        navigationController?.popViewController(animated: true)
    }
    
    func showCurrentRowDetail(indexPath: IndexPath) {
        self.tableView!.deselectRow(at: indexPath, animated: true)
        let selectedSight = self.currentSightList[indexPath.row]
        
        self.performSegue(withIdentifier: "ShowDetailViewSegue", sender: selectedSight)
    }
    
    // Searching bar functions
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredSights = currentSightList.filter({( sight : Sight) -> Bool in
            return sight.sightName!.contains(searchText)
        })
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowDetailViewSegue" {
            let controller = segue.destination as! DetailSightViewController
            controller.selectedSight = sender as? Sight
        } else if segue.identifier == "ViewListSegue" {
            
        }
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {}
    
    @IBAction func save(_ unwindSegue: UIStoryboardSegue) {}
        
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension AllSightsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

