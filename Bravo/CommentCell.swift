//
//  CommentCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/29/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class CommentCell: UITableViewCell {

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var comment: PFObject! {
        didSet {
            let sender = comment["sender"] as! BravoUser
            
            senderNameLabel.text = "\(sender["firstName"]!) \(sender["lastName"]!)"
            messageLabel.text = "+\(comment["points"]!) for \(comment["message"]!)"
            
            // Setting sender image view
            setImageView(imageView: senderImageView, user: sender)
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
