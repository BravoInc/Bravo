//
//  LeaderboardViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var searchBar: UISearchBar!
    
    var filteredLeaders = [PFObject]()
    var leaders = [PFObject]()
    var skillName: String = ""

    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a leader by skill"
        navigationItem.titleView = searchBar
        
        // Set up leaderboard search table view
        filteredLeaders = leaders
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "LeaderCell", bundle: nil), forCellReuseIdentifier: "LeaderCell")
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getLeaders), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getLeaders(refreshControl: progressControl.refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getLeaders(refreshControl: UIRefreshControl) {
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }

        UserSkillPoints.getUserPoints(success: { (userSkillPoints: [PFObject]?) in
            print ("-- got \(userSkillPoints?.count) leaders")
            self.leaders = userSkillPoints!
            self.filteredLeaders = self.leaders
            print ("-- leaders data: \(self.filteredLeaders)")
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true

        }, failure: {(error: Error?) -> () in
            print ("-- error getting user data: \(error?.localizedDescription)")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true
        })
    }
    
    func getSkillLeaders() {
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }
        Skills.getSkillPoints(skillName: skillName, success: { (userPoints: [PFObject]?) in
            print ("-- got \(userPoints?.count) leaders in \(self.skillName)")
            self.filteredLeaders = userPoints!
            print ("-- \(self.skillName) leaders data: \(self.filteredLeaders)")
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true
            
        }, failure: {(error: Error?) -> () in
            print ("-- error getting leader data for \(self.skillName): \(error?.localizedDescription)")
            self.filteredLeaders = []
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let leaderCell = tableView.dequeueReusableCell(withIdentifier: "LeaderCell", for: indexPath) as! LeaderCell
        if skillName.characters.count == 0 {
            leaderCell.leaderSkillPoints = filteredLeaders[indexPath.row]
        } else {
            filteredLeaders[indexPath.row]["skill"] = skillName
            leaderCell.skillPoints = filteredLeaders[indexPath.row]
        }
        return leaderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// SearchBar methods
extension LeaderboardViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        skillName = ""
        filteredLeaders = leaders
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        skillName = searchBar.text!
        isRefresh = false
        getSkillLeaders()
        searchBar.resignFirstResponder()
    }
}
