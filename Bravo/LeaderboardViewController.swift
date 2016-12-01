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
        
        getLeaders()
    }

    override func viewWillAppear(_ animated: Bool) {
        getLeaders()
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
    
    func getLeaders() {
        UserSkillPoints.getUserPoints(success: { (userSkillPoints: [PFObject]?) in
            print ("-- got \(userSkillPoints?.count) leaders")
            self.leaders = userSkillPoints!
            self.filteredLeaders = self.leaders
            print ("-- leaders data: \(self.filteredLeaders)")
            self.tableView.reloadData()

        }, failure: {(error: Error?) -> () in
            print ("-- error getting user data: \(error?.localizedDescription)")
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let leaderCell = tableView.dequeueReusableCell(withIdentifier: "LeaderCell", for: indexPath) as! LeaderCell
        leaderCell.leaderSkillPoints = filteredLeaders[indexPath.row]
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
        filteredLeaders = leaders
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filteredLeaders = leaders.filter { (leader : PFObject) -> Bool in
            return (leader["name"] as! NSString ).range(of: searchBar.text!, options: NSString.CompareOptions.caseInsensitive).location != NSNotFound
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
