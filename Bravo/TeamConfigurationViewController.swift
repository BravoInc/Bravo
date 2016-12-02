//
//  TeamSelectionViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let NUM_SECTIONS = 2
    
    let SECTION_USER_TEAMS = 0
    let SECTION_ALL_TEAMS = 1
    
    let USER_TEAMS_HEADER_TEXT = "My Teams"
    let ALL_TEAMS_HEADER_TEXT = "Other Teams"
    
    @IBOutlet weak var tableView: UITableView!
    var allTeams = [PFObject]()
    var userTeams = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName : "TeamCell", bundle : nil), forCellReuseIdentifier: "TeamCell")

        getUserTeams()
        getTeams()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_USER_TEAMS:
            return USER_TEAMS_HEADER_TEXT
        case SECTION_ALL_TEAMS:
            return ALL_TEAMS_HEADER_TEXT
        default:
            return ""
        }
    }
    
    func getTeams(){
        Team.getAllTeams(success: { (teams : [Team]?) in
            print("--- got \(teams?.count) teams")
            self.allTeams = teams!
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get All teams : \(error?.localizedDescription)")
        })
    }
    
    func getUserTeams(){
        Team.getUserTeams(user: BravoUser.getLoggedInUser(), success: { (userTeams : [PFObject]?) in
            print("--- got \(userTeams?.count) User teams")
            self.userTeams = userTeams!
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get user teams : \(error?.localizedDescription)")
        })
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
        let teamCell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamCell
        
        switch indexPath.section {
        case SECTION_USER_TEAMS:
            teamCell.team = userTeams[indexPath.row]
        case SECTION_ALL_TEAMS:
            teamCell.team = allTeams[indexPath.row]
        default: break
        }
        
        return teamCell

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
