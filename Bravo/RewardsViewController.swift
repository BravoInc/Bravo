//
//  RewardsViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/13/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class RewardsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var rewardPickLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var rewards: [String]!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set dummy rewards
        rewards = ["1 Day Off", "Free lunch", "Concert Ticket", "Movie Ticket"]
        // Set navigation bar title view
        navigationItem.titleView = rewardPickLabel
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "RewardCell", bundle: nil), forCellReuseIdentifier: "RewardCell")
        tableView.register(UINib(nibName: "MoreRewardsCell", bundle: nil), forCellReuseIdentifier: "MoreRewardsCell")
        
        tableView.reloadData()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewards.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < rewards.count) {
            let rewardCell = tableView.dequeueReusableCell(withIdentifier: "RewardCell") as! RewardCell
            rewardCell.rewardNameLabel.text = rewards[indexPath.row]
            return rewardCell
        } else {
            let moreRewardsCell = tableView.dequeueReusableCell(withIdentifier: "MoreRewardsCell") as! MoreRewardsCell
            return moreRewardsCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)

        let rewardVC = storyboard.instantiateViewController(withIdentifier: "RewardCreationViewController") as! RewardCreationViewController
        
        
        self.show(rewardVC, sender: self)
        
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
