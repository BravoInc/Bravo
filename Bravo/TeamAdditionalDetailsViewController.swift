//
//  TeamAdditionalDetailsViewController.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamAdditionalDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let SECTION_MEMBERS = 0
    let SECTION_REWARDS = 1
    
    let MEMBERS_SECTION_HEADER = "Members"
    let REWARDS_SECTION_HEADER = "Rewards"
    
    
    @IBOutlet weak var tableView: UITableView!
    var team : PFObject!
    var users = [PFUser]()
    var rewards = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set navigation bar title view
        let titleLabel = UILabel()
        titleLabel.text = team["name"] as! String?
        print("--- Details for team : \(team["name"])")
        titleLabel.sizeToFit()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 18)
        navigationItem.titleView = titleLabel
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.register(UINib(nibName: "RewardCell", bundle: nil), forCellReuseIdentifier: "RewardCell")
        
        getUsers()
        getTeamRewards()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_MEMBERS:
            return users.count
        case SECTION_REWARDS:
            return rewards.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_MEMBERS:
            return MEMBERS_SECTION_HEADER
        case  SECTION_REWARDS:
            return REWARDS_SECTION_HEADER
        default:
            return ""
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == SECTION_MEMBERS){
            let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            userCell.user = users[indexPath.row]
            userCell.setImageViews()
            return userCell
        } else {
            let rewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as! RewardCell
            rewardCell.reward = rewards[indexPath.row]
            return rewardCell
        }
    }
    
    func getUsers(){
        BravoUser.getTeamUsers(team: team, success: { (users : [PFUser]?) in
            print("--- got \(users?.count) users")
            self.users = users!
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get users : \(error?.localizedDescription)")
        })
    }
    
    func getTeamRewards(){
        Team.getTeamRewards(team: team, success: { (rewards : [PFObject]?) in
            print("--- got \(rewards?.count) rewards")
            self.rewards = rewards!
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! failed to get rewards")
        })
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
