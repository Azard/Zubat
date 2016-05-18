//
//  StationsViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/19/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit
import AVFoundation

class StationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var videos = [Video]()

    var searchVideos = [Video]()
    var searchController : UISearchController!
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register 'Nothing Found' cell xib
        let cellNib = UINib(nibName: "NothingFoundCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "NothingFound")
        
        loadVideoData()
        // Setup TableView
        tableView.backgroundColor = UIColor.clearColor()
        tableView.backgroundView = nil
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        
        searchController = UISearchController(searchResultsController: nil)
        
        if searchable {
            searchController.searchResultsUpdater = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            
            // Add UISearchController to the tableView
            tableView.tableHeaderView = searchController?.searchBar
            tableView.tableHeaderView?.backgroundColor = UIColor.clearColor()
            definesPresentationContext = true
            searchController.hidesNavigationBarDuringPresentation = false
            
            // Style the UISearchController
            searchController.searchBar.barTintColor = UIColor.clearColor()
            searchController.searchBar.tintColor = UIColor.whiteColor()
            
            // Hide the UISearchController
            tableView.setContentOffset(CGPoint(x: 0.0, y: searchController.searchBar.frame.size.height), animated: false)
            
            // Set a black keyborad for UISearchController's TextField
            let searchTextField = searchController.searchBar.valueForKey("_searchField") as! UITextField
            searchTextField.keyboardAppearance = UIKeyboardAppearance.Dark
        }
    }

    
    
    
    func loadVideoData(){
        videos = Video.listAllVideo()
        dispatch_async(dispatch_get_main_queue()){
            self.tableView.reloadData()
            self.view.setNeedsDisplay()
        }
        
    }
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NowPlaying" {
            let display = segue.destinationViewController as! DisplayController
            if let index = (sender as? NSIndexPath){
                let video = videos[index.row]
                display.curVideo = video.videoName
            }else{
                print("no video")
            }
        }else if segue.identifier == "editVideo"{
            let nowEditVC = segue.destinationViewController as! EditVideoController
            if let index = (sender as? NSIndexPath){
                let video = videos[index.row]
                nowEditVC.curVideo = video.videoName
            }else{
                print("no video")
            }
            
        }
    }
}

//*****************************************************************
// MARK: - TableViewDataSource
//*****************************************************************

extension StationsViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The UISeachController is active
        if searchController.active {
            return searchVideos.count
            
        // The UISeachController is not active
        } else {
            if videos.count == 0 {
                return 1
            } else {
                return videos.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if videos.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("NothingFound", forIndexPath: indexPath) 
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as! StationTableViewCell
            
            // alternate background color
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.clearColor()
            } else {
                cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            }
             if searchController.active {
                //let station = searchedStations[indexPath.row]
                let video = videos[indexPath.row]
                cell.configureStationCell(video)
                
            // The UISeachController is not active
            } else {
                let video = videos[indexPath.row]
                cell.configureStationCell(video)
            }
            
            return cell
        }
        
    }
    
}

//*****************************************************************
// MARK: - TableViewDelegate
//*****************************************************************

extension StationsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if !videos.isEmpty {
            
            performSegueWithIdentifier("NowPlaying", sender: indexPath)
        }
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView,editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .Normal, title: "Edit") { action, index in
            self.performSegueWithIdentifier("editVideo", sender: indexPath)
        }
        edit.backgroundColor = UIColor.orangeColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            let video = self.videos[indexPath.row]
            self.videos.removeAtIndex(indexPath.row)
            Video.deleteVideo(video.videoName)
            self.tableView.reloadData()
        }
        delete.backgroundColor = UIColor.redColor()
        
    
        
        return [edit, delete]
    }
}


//*****************************************************************
// MARK: - UISearchControllerDelegate
//*****************************************************************

extension StationsViewController: UISearchResultsUpdating {

    func updateSearchResultsForSearchController(searchController: UISearchController) {
    
        // Empty the searchedStations array
        searchVideos.removeAll(keepCapacity: false)

        let searchPredicate = NSPredicate(format: "SELF.videoName CONTAINS[c] %@", searchController.searchBar.text!)

        let array = (self.videos as NSArray).filteredArrayUsingPredicate(searchPredicate)

        searchVideos = array as! [Video]
    
        // Reload the tableView
        self.tableView.reloadData()
    }
    
}
