//
//  RewardCreationViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/13/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse


@objc protocol RewardCreationViewControllerDelegate {
    @objc optional func rewardCreationViewController(rewardCreationViewController: RewardCreationViewController, reward: PFObject)
}

class RewardCreationViewController: UIViewController {
    @IBOutlet weak var rewardNameTextField: UITextField!
    @IBOutlet weak var rewardPointsTextField: UITextField!
    
    var currentTeam : PFObject!
    weak var delegate: RewardCreationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    @IBAction func onButtonPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        let newReward = Reward.createReward(team : currentTeam, rewardName : rewardNameTextField.text!, rewardPoints: Int(rewardPointsTextField.text ?? "0")! , isActive: true)
        delegate?.rewardCreationViewController?(rewardCreationViewController: self, reward: newReward)
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
