//
//  RewardCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/14/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class RewardCell: UITableViewCell {

    @IBOutlet weak var rewardNameLabel: UILabel!
    @IBOutlet weak var rewardPointsLabel: UILabel!
    @IBOutlet weak var rewardSwitch: UISwitch!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
