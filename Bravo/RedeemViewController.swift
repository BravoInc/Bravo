//
//  RedeemViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

@objc protocol RedeemViewControllerDelegate {
    @objc optional func updatePoints(redeemedPoints: Int, userSkillPoint: PFObject)
}

class RedeemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var availableTeams = [Int: String]()
    var teamSections = [String: Int]()
    var availableRewards = [Int: [PFObject]]()
    var indexSelection = [Int: [Int: Bool]]()
    var selectedPoints = 0
    var availableRewardPoints: Int!
    var userSkillPoint: PFObject?
    weak var delegate: RedeemViewControllerDelegate?
    
    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up reward lookup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "RewardCell", bundle: nil), forCellReuseIdentifier: "RewardCell")
        
        // Set navigation bar title view
        let titleLabel = UILabel()
        titleLabel.text = "Redeem Points"
        titleLabel.sizeToFit()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 18)
        navigationItem.titleView = titleLabel

        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getAvailableRewards), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getAvailableRewards(refreshControl: progressControl.refreshControl)
    }

    
    func getAvailableRewards(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }

        Reward.getAvailableRewards(user: BravoUser.getLoggedInUser(), success: { (rewards : [PFObject]?) in
            print("--- got \(rewards?.count) rewards")
            
            var section = 0
            for reward in rewards! {
                let team = "\((reward["team"] as! PFObject)["name"]!)"
                if self.teamSections[team] == nil {
                    self.teamSections[team] = section
                    self.availableTeams[section] = team
                    self.availableRewards[section] = [PFObject]()
                    self.indexSelection[section] = [Int: Bool]()
                    section += 1
                }
                let teamSection = self.teamSections[team]!
                self.availableRewards[teamSection]!.append(reward)
                let rowIndex = self.availableRewards[teamSection]!.count - 1
                self.indexSelection[teamSection]![rowIndex] = false
                
            }
            
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true

        }, failure: { (error : Error?) in
            print("---!!! cant get rewards : \(error?.localizedDescription)")
            self.availableRewards = [Int: [PFObject]]()
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true

        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return teamSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRewards[section]!.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return availableTeams[section]
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
        let rewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as! RewardCell
        rewardCell.isChecked = indexSelection[indexPath.section]![indexPath.row]!
        rewardCell.reward = availableRewards[indexPath.section]![indexPath.row]
        
        if availableRewardPoints < (rewardCell.reward["points"]! as! Int) {
            rewardCell.isUserInteractionEnabled = false
            rewardCell.rewardNameLabel.isEnabled = false
            rewardCell.rewardPointsLabel.isEnabled = false
        } else {
            rewardCell.isUserInteractionEnabled = true
            rewardCell.rewardNameLabel.isEnabled = true
            rewardCell.rewardPointsLabel.isEnabled = true
        }
        return rewardCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currIndexValue = indexSelection[indexPath.section]![indexPath.row]!
        indexSelection[indexPath.section]![indexPath.row] = !currIndexValue
        
        if indexSelection[indexPath.section]![indexPath.row]! {
            selectedPoints += (availableRewards[indexPath.section]![indexPath.row]["points"]! as! Int)
        } else {
            selectedPoints -= (availableRewards[indexPath.section]![indexPath.row]["points"]! as! Int)
        }
        
        if selectedPoints == 0 || selectedPoints > availableRewardPoints {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Redeem", style: .plain, target: self, action: #selector(onRedeem(_:)))
        }
        
        //tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func onRedeem(_ sender: UIBarButtonItem) {
        var numRewards = 0
        var redeemRewards = [PFObject]()
        
        for i in 0..<availableRewards.count {
            for j in 0..<availableRewards[i]!.count {
                if indexSelection[i]![j]! {
                    numRewards += 1
                    availableRewards[i]![j]["isClaimed"] = true
                    availableRewards[i]![j]["claimedBy"] = BravoUser.getLoggedInUser()
                    redeemRewards.append(availableRewards[i]![j])
                }
            }
 
        }

        let rewardsStr = numRewards == 1 ? "reward" : "rewards"
        displayMessage(title: "Bravo!", subTitle: "You have successfully redeemed \(numRewards) \(rewardsStr)!", duration: 3.0, showCloseButton: false, messageStyle: .success)

        self.userSkillPoint!.incrementKey("availablePoints", byAmount: NSNumber(value: -self.selectedPoints))
        
        delegate?.updatePoints?(redeemedPoints: self.selectedPoints, userSkillPoint: self.userSkillPoint!)
        
        Reward.updateRewards(rewards: redeemRewards, success: {
            (rewards: [PFObject]?) -> () in
            print ("-- Successfully updated rewards")
            
            UserSkillPoints.updateUserPoints(userSkillPoint: self.userSkillPoint!, success: { (userSkillPoint: PFObject?) in
                print ("-- user points adjusted successfully")
            }, failure: { (error: Error?) in
                print (" -- error updating user points: \(error?.localizedDescription)")
            })
        }, failure: {
            (error: Error?) -> () in
            print ("-- Error updating rewards: \(error?.localizedDescription)")
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            self.navigationController?.popViewController(animated: true)
        }

        
    }
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell: cell, withTransform: CellAnimator.TransformFlip, andDuration: 1)
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
