//
//  TeamCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamCell: UITableViewCell {

    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var selectionImageView: UIView!
    
    var team: PFObject! {
        didSet {
            teamNameLabel.text = "\(team["name"]!)"
            let adminUser = team["adminUser"] as! BravoUser
            adminLabel.text = "\(adminUser["firstName"]!) \(adminUser["lastName"]!)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor
        self.layer.shadowRadius = 3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
