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
    var userPointsMap = [String: Int]()
    var selectedIndex: Int = -1

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
        searchBar.placeholder = "Search for a user"
        navigationItem.titleView = searchBar

        // Set navigation bar title view
        /*let titleLabel = UILabel()
        titleLabel.text =
        "Select Recipient"
        titleLabel.sizeToFit()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        navigationItem.titleView = titleLabel
        */
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getUsers), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getUsers(refreshControl: progressControl.refreshControl)

    }

    func getUsers(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }

        BravoUser.getTeamUsers(team: currentTeam, success: { (users : [PFUser]?) in
            print("--- got \(users?.count) users")
            self.filteredUsers = users!
            self.users = users!
            
            UserSkillPoints.getUserTotalPoints(users: self.users, success: { (userSkillPoints: [PFObject]?) in
                for userPoint in userSkillPoints! {
                    self.userPointsMap[(userPoint["user"] as! PFUser).objectId!] = (userPoint["totalPoints"]! as! Int)
                }
                self.tableView.reloadData()
                self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
                self.isRefresh = true

            }, failure: { (error: Error?) in
                print ("--error getting user points \(error?.localizedDescription)")
                self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
                self.isRefresh = true

            })
            
        }, failure: { (error : Error?) in
            print("---!!! cant get users : \(error?.localizedDescription)")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true

        })
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        userCell.points = userPointsMap[filteredUsers[indexPath.row].objectId!] ?? 0
        userCell.user = filteredUsers[indexPath.row]
        if userCell.user.objectId! == PFUser.current()!.objectId {
            userCell.isUserInteractionEnabled = false
            userCell.userFullNameLabel.isEnabled = false
            userCell.userNameLabel.isEnabled = false
            userCell.userPointsLabel.isEnabled = false
            userCell.profileImageView.alpha = 0.5
            userCell.isChecked = false
        } else {
            userCell.isUserInteractionEnabled = true
            userCell.userFullNameLabel.isEnabled = true
            userCell.userNameLabel.isEnabled = true
            userCell.userPointsLabel.isEnabled = true
            userCell.profileImageView.alpha = 1
            userCell.isChecked = selectedIndex == indexPath.row
        }
        
        userCell.setImageViews()
        
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let oldIndex = selectedIndex
        selectedIndex = indexPath.row
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onDone(_:)))
        tableView.reloadRows(at: [indexPath], with: .none)
        if oldIndex >= 0 {
            let oldIndexPath = IndexPath(row: oldIndex, section: indexPath.section)
            tableView.reloadRows(at: [oldIndexPath], with: .none)
        }
        
    }
    
    func onDone(_ sender: UIBarButtonItem) {
        let presentingNavController = self.presentingViewController as! UINavigationController
        if let postComposeVC = (presentingNavController.viewControllers[0] as?PostComposeViewController) {
            postComposeVC.user = filteredUsers[selectedIndex]
            postComposeVC.recipientTextField.text = "\(postComposeVC.user!["firstName"]!) \(postComposeVC.user!["lastName"]!)"
        }
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
