//
//  PostCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class PostCell: UITableViewCell {

    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var recipientImageView: UIImageView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    var post: PFObject! {
        didSet {
            // Image Views
            //let sender = post["sender"] as! BravoUser
            let recipient = post["recipient"] as! BravoUser
            
            recipientNameLabel.text = "\(recipient["firstName"]!) \(recipient["lastName"]!)"
            messageLabel.text = "+\(post["points"]!) for \(post["message"]!) #\(post["skill"]!)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
