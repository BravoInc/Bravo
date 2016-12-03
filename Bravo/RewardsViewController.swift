//
//  RewardsViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/13/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class RewardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RewardCreationViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var defaultRewards = [PFObject]()
    var currentTeam : PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default rewards
        let rewards = [("1 Day Off", 2000), ("Free lunch", 200), ("Concert Ticket", 1000), ("Movie Ticket", 300)]
        
        for reward in rewards {
            let newReward = Reward.createReward(team : currentTeam, rewardName : reward.0, rewardPoints: reward.1, isActive: true)
            defaultRewards.append(newReward)
        }
        // Set navigation bar title view
        let titleLabel = UILabel()
        titleLabel.text =
            "Pick Rewards"
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        self.navigationItem.setHidesBackButton(true, animated:false);
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(onSubmit(_:)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60

        tableView.register(UINib(nibName: "RewardCell", bundle: nil), forCellReuseIdentifier: "RewardCell")
        tableView.register(UINib(nibName: "MoreRewardsCell", bundle: nil), forCellReuseIdentifier: "MoreRewardsCell")
        
        tableView.reloadData()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultRewards.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < defaultRewards.count) {
            let rewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell") as! RewardCell
            rewardCell.reward = defaultRewards[indexPath.row]
            
            return rewardCell
        } else {
            let moreRewardsCell = tableView.dequeueReusableCell(withIdentifier: "MoreRewardsCell") as! MoreRewardsCell
            return moreRewardsCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.row < defaultRewards.count) {
            return
        }
        let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
        
        let rewardCreationNavController = storyboard.instantiateViewController(withIdentifier: "RewardsCreationNavigationController") as! UINavigationController
        
        let rewardVC = storyboard.instantiateViewController(withIdentifier: "RewardCreationViewController") as! RewardCreationViewController
        rewardVC.currentTeam = self.currentTeam
        rewardVC.delegate = self
        rewardCreationNavController.setViewControllers([rewardVC], animated: true)
        self.present(rewardCreationNavController, animated: true, completion: nil)
    }
    
    func onSubmit(_ sender: UIBarButtonItem) {
        Reward.createRewards(rewards: defaultRewards,team : currentTeam, success: {
            print("--- Reward creation succes")
            self.navigationController?.popToRootViewController(animated: true)
            
        }, failure: { (error : Error?) in
            print("---!!! reward creation error : \(error?.localizedDescription)")
        })
    }

    func rewardCreationViewController(rewardCreationViewController: RewardCreationViewController, reward: PFObject) {
        defaultRewards.append(reward)
        tableView.reloadData()
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
