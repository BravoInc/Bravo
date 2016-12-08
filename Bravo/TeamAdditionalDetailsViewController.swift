//
//  TeamAdditionalDetailsViewController.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

@objc protocol TeamAdditionalDetailsViewControllerDelegate {
    @objc optional func joinTeam(team: PFObject)
}

class TeamAdditionalDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let SECTION_MEMBERS = 0
    let SECTION_REWARDS = 1
    
    let MEMBERS_SECTION_HEADER = "Members"
    let REWARDS_SECTION_HEADER = "Rewards"
    
    @IBOutlet weak var tableView: UITableView!
    var team : PFObject!
    var users = [PFUser]()
    var rewards = [PFObject]()
    var userPointsMap = [String: Int]()
    
    var canJoinTeam = false
    
    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false
    weak var delegate: TeamAdditionalDetailsViewControllerDelegate?
    

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
        
        if canJoinTeam {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Join", style: .plain, target: self, action: #selector(joinTapped))
        }
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        tableView.register(UINib(nibName: "RewardCell", bundle: nil), forCellReuseIdentifier: "RewardCell")
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getUsers), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getUsers(refreshControl: progressControl.refreshControl)
    }
    
    func joinTapped(){
        print("--- Join team tapped ")
        Team.joinTeam(team: team, success: {
            print("--- Join Team Success")
            displayMessage(title: "Bravo!", subTitle: "You are now a member of \(self.team["name"]!)!", duration: 3.0, showCloseButton: false, messageStyle: .success)

//            let message = "Your request to join Team \(self.filteredTeams[indexPath.row]["name"]!) has been sent to the administrator.\n\nYou will be notified when the admin approves."
//            let alert = UIAlertController(title: "Request Sent", message: message, preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//                action in switch(action.style) {
//                case .default:
//                    let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
//                    let teamNavController = storyboard.instantiateViewController(withIdentifier: "TeamNavigationController") as! UINavigationController
//                    self.present(teamNavController, animated: true, completion: nil)
//                    
//                default:
//                    break
//                }
//            }))
//            self.present(alert, animated: true, completion: nil)
            self.delegate?.joinTeam?(team: self.team)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }, failure: { (error : Error?) in
            print("---!!! Failed to join team : \(error?.localizedDescription) ")
        })

    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView, let textLabel = headerView.textLabel {
            
            textLabel.font = UIFont(name: "Avenir-Medium", size: CGFloat(16.0))
            textLabel.textAlignment = .center
            textLabel.textColor = UIColor.white
            headerView.tintColor = purpleColor
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == SECTION_MEMBERS){
            let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            userCell.points = userPointsMap[users[indexPath.row].objectId!] ?? 0
            userCell.user = users[indexPath.row]
            userCell.setImageViews()
            return userCell
        } else {
            let rewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as! RewardCell
            rewardCell.reward = rewards[indexPath.row]
            rewardCell.selectionImageWidth.constant = 0
            rewardCell.rewardNameLeading.constant = 0
            rewardCell.isUserInteractionEnabled = false
            return rewardCell
        }
    }
    
    func getUsers(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }

        BravoUser.getTeamUsers(team: team, success: { (users : [PFUser]?) in
            print("--- got \(users?.count) users")
            self.users = users ?? self.users
            self.getTeamRewards()
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get users : \(error?.localizedDescription)")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true

        })
    }
    
    func getTeamRewards(){
        Team.getTeamRewards(team: team, success: { (rewards : [PFObject]?) in
            print("--- got \(rewards?.count) rewards")
            self.rewards = rewards ?? self.rewards
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
            print("---!!! failed to get rewards")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true

            
        })
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell: cell, withTransform: CellAnimator.TransformTilt, andDuration: 1)
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
