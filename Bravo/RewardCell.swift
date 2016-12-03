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
    
    var reward: PFObject! {
        didSet {
            rewardNameLabel.text = "\(reward["name"]!) - "
            rewardPointsLabel.text = "\(reward["points"]!) points"
        }
    }
    
    var isChecked: Bool = false
    
    func setImageViews() {
        selectionImageView.image = UIImage(named: isChecked ? "selectedSquare" : "borderSquare")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
