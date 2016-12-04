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
    
    var availableRewards = [PFObject]()
    var indexSelection = [Int: Bool]()
    var selectedPoints = 0
    var availableRewardPoints: Int!
    var userSkillPoint: PFObject?
    weak var delegate: RedeemViewControllerDelegate?
    
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

        getAvailableRewards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAvailableRewards()
    }
    
    func getAvailableRewards(){
        Reward.getAvailableRewards(user: BravoUser.getLoggedInUser(), success: { (rewards : [PFObject]?) in
            print("--- got \(rewards?.count) rewards")
            self.availableRewards = rewards!
            for i in 0..<self.availableRewards.count {
                self.indexSelection[i] = false
            }
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get rewards : \(error?.localizedDescription)")
            self.availableRewards = [PFObject]()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableRewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell", for: indexPath) as! RewardCell
        rewardCell.reward = availableRewards[indexPath.row]
        rewardCell.isChecked = indexSelection[indexPath.row]!
        rewardCell.setImageViews()
        
        if availableRewardPoints < (availableRewards[indexPath.row]["points"]! as! Int) {
            rewardCell.isUserInteractionEnabled = false
            rewardCell.backgroundColor = extraLightGreyColor
        } else {
            rewardCell.isUserInteractionEnabled = true
            rewardCell.backgroundColor = UIColor.white
        }
        return rewardCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexSelection[indexPath.row] = !indexSelection[indexPath.row]!
        
        if indexSelection[indexPath.row]! {
            selectedPoints += (availableRewards[indexPath.row]["points"]! as! Int)
        } else {
            selectedPoints -= (availableRewards[indexPath.row]["points"]! as! Int)
        }
        
        if selectedPoints == 0 || selectedPoints > availableRewardPoints {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Redeem", style: .plain, target: self, action: #selector(onRedeem(_:)))
        }
        
        tableView.reloadData()
    }
    
    func onRedeem(_ sender: UIBarButtonItem) {
        for i in 0..<availableRewards.count {
            if indexSelection[i]! {
                availableRewards[i]["isClaimed"] = true
                availableRewards[i]["claimedBy"] = BravoUser.getLoggedInUser()
            }
        }

        self.userSkillPoint!["availablePoints"] = (self.userSkillPoint!["availablePoints"] as! Int) - self.selectedPoints
        
        delegate?.updatePoints?(redeemedPoints: self.selectedPoints, userSkillPoint: self.userSkillPoint!)
        
        Reward.updateRewards(rewards: availableRewards, success: {
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
        
        navigationController?.popViewController(animated: true)
        
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
