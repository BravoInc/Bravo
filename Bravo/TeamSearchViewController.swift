//
//  TeamSearchViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar: UISearchBar!
    
    var filteredTeams = [PFObject]()
    var teams = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for an existing team"
        navigationItem.titleView = searchBar
        
        // Set up team search table view
        filteredTeams = teams
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60

        tableView.register(UINib(nibName: "TeamCell", bundle: nil), forCellReuseIdentifier: "TeamCell")
        
        getTeams()
    }
    
    func getTeams(){
        Team.getAllTeams(success: { (teams : [Team]?) in
            print("--- got \(teams?.count) teams")
            self.filteredTeams = teams!
            self.teams = teams!
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get teams : \(error?.localizedDescription)")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        if ((filteredTeams[indexPath.row]["adminUser"] as! BravoUser).objectId == BravoUser.getLoggedInUser().objectId) {
            showTeamErrorDialog(teamName: filteredTeams[indexPath.row]["name"] as! String)
            return
        } 
        
        Team.joinTeam(team: filteredTeams[indexPath.row], success: {
            let message = "Your request to join Team \(self.filteredTeams[indexPath.row]["name"]!) has been sent to the administrator.\n\nYou will be notified when the admin approves."
            let alert = UIAlertController(title: "Request Sent", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                action in switch(action.style) {
                case .default:
                    let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
                    let teamNavController = storyboard.instantiateViewController(withIdentifier: "TeamNavigationController") as! UINavigationController
                    self.present(teamNavController, animated: true, completion: nil)
                    
                default:
                    break
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        }, failure: { (error : Error?) in
            print("---!!! Failed to join team : \(error?.localizedDescription) ")
        })

    }
    
    func showTeamErrorDialog(teamName: String) {
        let message = "You are admin of the team \(teamName)."
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
extension TeamSearchViewController: UISearchBarDelegate {
    
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
