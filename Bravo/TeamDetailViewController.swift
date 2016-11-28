//
//  TeamDetailViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/27/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var currentTeam: PFObject!
    var searchBar: UISearchBar!
    
    var filteredUsers = [PFUser]()
    var users = [PFUser]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for a user"
        navigationItem.titleView = searchBar

        // Set navigation bar title view
        let titleLabel = UILabel()
        titleLabel.text =
        "Select Recipient"
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        getUsers()

    }

    func getUsers(){
        BravoUser.getTeamUsers(team: currentTeam, success: { (users : [PFUser]?) in
            print("--- got \(users?.count) users")
            self.filteredUsers = users!
            self.users = users!
            
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get users : \(error?.localizedDescription)")
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        userCell.user = filteredUsers[indexPath.row]
        
        
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
extension TeamDetailViewController: UISearchBarDelegate {
    
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
        filteredUsers = users
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filteredUsers = users.filter { (user : PFObject) -> Bool in
            return ("\(user["firstName"]) \(user["lastName"])" as NSString ).range(of: searchBar.text!, options: NSString.CompareOptions.caseInsensitive).location != NSNotFound
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
