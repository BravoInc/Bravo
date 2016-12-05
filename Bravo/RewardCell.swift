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
    @IBOutlet weak var rewardPointsLabel: UILabel!
    @IBOutlet weak var selectionImageView: UIImageView!
    var isChecked: Bool = false
    
    @IBOutlet weak var selectionImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var rewardNameLeading: NSLayoutConstraint!
    
    var reward: PFObject! {
        didSet {
            rewardNameLabel.text = "\(reward["name"]!)"
            rewardPointsLabel.text = "\(reward["points"]!) pts"
            selectionImageView.image = UIImage(named: isChecked ? "check128green" : "check128lightGray")
            selectionImageView.alpha = isChecked ? 1.0 : 0.3

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if(isChecked == true){
            selectionImageView.alpha = 1.0
            selectionImageView.image = UIImage(named: "check128green")
        }else{
            selectionImageView.image = UIImage(named: "check128lightGray")
            selectionImageView.alpha = 0.3
        }
        
        // Configure the view for the selected state
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
