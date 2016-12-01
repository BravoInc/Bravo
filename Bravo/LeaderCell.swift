//
//  LeaderCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/30/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class LeaderCell: UITableViewCell {

    
    @IBOutlet weak var leaderImageView: UIImageView!
    @IBOutlet weak var leaderNameLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    
    var leaderSkillPoints: PFObject! {
        didSet {
            let leader = leaderSkillPoints["user"] as! BravoUser
            
            leaderNameLabel.text = "\(leader["firstName"]!) \(leader["lastName"]!)"
            totalPointsLabel.text = "\(leaderSkillPoints["totalPoints"]!) total points"
            skillsLabel.text = "\((leaderSkillPoints["skills"]! as! Array).joined(separator: ", "))"

            // Setting leader image view
            setImageView(imageView: leaderImageView, user: leader)
        }
    }

    var skillPoints: PFObject! {
        didSet {
            // TODO: Add Image Views
            let leader = skillPoints["user"] as! BravoUser
            
            leaderNameLabel.text = "\(leader["firstName"]!) \(leader["lastName"]!)"
            totalPointsLabel.text = "\(skillPoints["points"]!) total points"
            skillsLabel.text = "\(skillPoints["skill"]!)"
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
    
}
