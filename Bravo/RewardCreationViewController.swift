//
//  RewardCreationViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/13/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class RewardCreationViewController: UIViewController {
    var currentTeam : PFObject!
    
    @IBOutlet weak var rewardPointsTextField: UITextField!

    @IBOutlet weak var rewardNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateTapped(_ sender: Any) {
        Reward.createReward(team: currentTeam, rewardName: rewardNameTextField.text!, rewardPoints: Int(rewardPointsTextField.text!)! , success: {
            print("--- Reward creation succes")
        }, failure: { (error : Error?) in
            print("---!!! reward creation error : \(error?.localizedDescription)")
        })
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
