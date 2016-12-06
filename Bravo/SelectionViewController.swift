//
//  SelectionViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/27/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class SelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar!
    
    var filteredTeams = [PFObject]()
    var teams = [PFObject]()
    
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
        searchBar.placeholder = "Search for a team"
        navigationItem.titleView = searchBar

        navigationItem.rightBarButtonItem = nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Team", style: .plain, target: nil, action: nil)

        // Set up team search table view
        filteredTeams = teams
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "TeamCell", bundle: nil), forCellReuseIdentifier: "TeamCell")
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getTeams), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getTeams(refreshControl: progressControl.refreshControl)
    }

    func getTeams(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }

        Team.getUserTeams(user: BravoUser.getLoggedInUser(), success: { (teams : [PFObject]?) in
            print("--- got \(teams?.count) teams")
            self.filteredTeams = teams!
            self.teams = teams!
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh)
            self.isRefresh = true
        }, failure: { (error : Error?) in
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh)
            self.isRefresh = true
            print("---!!! cant get teams : \(error?.localizedDescription)")
        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let teamCell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamCell
        teamCell.team = filteredTeams[indexPath.row]
        
        
        return teamCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showTeamDetails(team: filteredTeams[indexPath.row])
    }
    
    func showTeamDetails(team: PFObject) {
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let teamDetailVC = storyboard.instantiateViewController(withIdentifier: "TeamDetailViewController") as! TeamDetailViewController

        teamDetailVC.currentTeam = team
        let presentingNavController = self.presentingViewController as! UINavigationController
        (presentingNavController.viewControllers[0] as! PostComposeViewController).team = team
        
        self.show(teamDetailVC, sender: self)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

}

// SearchBar methods
extension SelectionViewController: UISearchBarDelegate {
    
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
        filteredTeams = teams
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filteredTeams = teams.filter { (team : PFObject) -> Bool in
            return (team["name"] as! NSString ).range(of: searchBar.text!, options: NSString.CompareOptions.caseInsensitive).location != NSNotFound
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
