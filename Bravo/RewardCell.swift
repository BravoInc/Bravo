//
//  RewardCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/14/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class RewardCell: UITableViewCell {

    @IBOutlet weak var rewardNameLabel: UILabel!
    @IBOutlet weak var rewardPointsField: UITextField!
    @IBOutlet weak var rewardSwitch: UISwitch!
    
    var reward: PFObject! {
        didSet {
            rewardNameLabel.text = "\(reward["name"]!)"
            rewardPointsField.text = "\(reward["points"]!)"
            rewardSwitch.isOn = reward["isActive"]! as! Bool
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onSwitchChanged(_ sender: Any) {
        reward["isActive"] = rewardSwitch.isOn
    }
    
    @IBAction func textChanged(_ sender: Any) {
        reward["points"] = Int(rewardPointsField.text!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
