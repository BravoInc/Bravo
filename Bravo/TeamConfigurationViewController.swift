//
//  TeamSelectionViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

import DZNEmptyDataSet

class TeamConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TeamPhotoViewControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let NUM_SECTIONS = 2
    
    let SECTION_USER_TEAMS = 0
    let SECTION_ALL_TEAMS = 1
    
    let USER_TEAMS_HEADER_TEXT = "My Teams"
    let ALL_TEAMS_HEADER_TEXT = "Other Teams"
    
    @IBOutlet weak var tableView: UITableView!
    var allTeams = [PFObject]()
    var userTeams = [PFObject]()
    var tempRewards = [PFObject]()
    
    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        // for DZNEmpty
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName : "TeamCell", bundle : nil), forCellReuseIdentifier: "TeamCell")
        //tableView.register(UINib(nibName : "AddTeamCell", bundle : nil), forCellReuseIdentifier: "AddTeamCell")
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getUserTeams), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getUserTeams(refreshControl: progressControl.refreshControl)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_USER_TEAMS:
            if(userTeams.count == 0 ){
                return ""
            }else{
                return USER_TEAMS_HEADER_TEXT
            }
        case SECTION_ALL_TEAMS:
            if(allTeams.count == 0){
                return ""
            }else{
                return ALL_TEAMS_HEADER_TEXT
            }
            
        default:
            return ""
        }
    }
    
    func getTeams(refreshControl: UIRefreshControl){
        Team.getAllTeams(userTeams: self.userTeams, success: { (teams : [Team]?) in
            print("--- got \(teams?.count) teams")
            self.allTeams = teams!
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh)
            self.isRefresh = true
        }, failure: { (error : Error?) in
            print("---!!! cant get All teams : \(error?.localizedDescription)")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh)
            self.isRefresh = true
        })
    }
    
    func getUserTeams(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }
        Team.getUserTeams(user: BravoUser.getLoggedInUser(), success: { (userTeams : [PFObject]?) in
            print("--- got \(userTeams?.count) User teams")
            self.userTeams = userTeams!
            self.getTeams(refreshControl: refreshControl)
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get user teams : \(error?.localizedDescription)")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh)
            self.isRefresh = true
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_USER_TEAMS:
            return userTeams.count
        case SECTION_ALL_TEAMS:
            return allTeams.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case SECTION_USER_TEAMS:
            if (indexPath.row < userTeams.count){
                let teamCell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamCell
                teamCell.team = userTeams[indexPath.row]
                return teamCell
            } /*
             else {
             let addTeamCell = tableView.dequeueReusableCell(withIdentifier: "AddTeamCell", for: indexPath) as! AddTeamCell
             return addTeamCell
             
             } */
        case SECTION_ALL_TEAMS:
            let teamCell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamCell
            teamCell.team = allTeams[indexPath.row]
            return teamCell
        default: break
        }
        let fakeCell = UITableViewCell()
        return fakeCell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
        
        print("--- all good 1")
        let teamAdditionalDetailsViewController = storyboard.instantiateViewController(withIdentifier: "TeamAdditionalDetailsViewController") as! TeamAdditionalDetailsViewController
        print("--- all good 2")
        
        
        if (indexPath.section == SECTION_USER_TEAMS) {
            teamAdditionalDetailsViewController.team = userTeams[indexPath.row]
            teamAdditionalDetailsViewController.users = [PFUser.current()!]
            teamAdditionalDetailsViewController.rewards = tempRewards
        } else {
            teamAdditionalDetailsViewController.team = allTeams[indexPath.row]
            teamAdditionalDetailsViewController.canJoinTeam = true
        }
        
        self.navigationController?.pushViewController(teamAdditionalDetailsViewController, animated: true)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView, let textLabel = headerView.textLabel {
            
            textLabel.font = UIFont(name: "Avenir-Medium", size: CGFloat(16.0))
            textLabel.textAlignment = .center
            textLabel.textColor = UIColor.white
            headerView.tintColor = purpleColor
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToTeamConfig(segue: UIStoryboardSegue) {
        print ("unwind successfull")
    }
    
    func addTeam(team: PFObject, rewards: [PFObject]) {
        userTeams.insert(team, at: 0)
        tempRewards = rewards
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let teamPhotoNav = segue.destination as! UINavigationController
        let teamPhotoVC = teamPhotoNav.topViewController as! TeamPhotoViewController
        teamPhotoVC.delegate = self
    }
    
    
    /*
     // for empty data set: pick one
     
     func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
     let str = "Welcome"
     let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
     return NSAttributedString(string: str, attributes: attrs)
     }
     
     func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
     return UIImage(named: "taylor-swift")
     }
     
     func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
     let str = "Add Grokkleglob"
     let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.callout)]
     return NSAttributedString(string: str, attributes: attrs)
     }
     

     func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
     let ac = UIAlertController(title: "Button tapped!", message: nil, preferredStyle: .alert)
     ac.addAction(UIAlertAction(title: "Hurray", style: .default))
     present(ac, animated: true)
     }

     */
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap 'Create' to start your own team"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    
} // last close curly


  
