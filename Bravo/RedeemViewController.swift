//
//  RedeemViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse


class RedeemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var availableRewards = [PFObject]()
    var indexSelection = [Int: Bool]()
    
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        navigationItem.titleView = titleLabel

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

        return rewardCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        indexSelection[indexPath.row] = !indexSelection[indexPath.row]!
        tableView.reloadData()

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
