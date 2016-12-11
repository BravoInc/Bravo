//
//  CommentCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/29/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse
import DateTools

class CommentCell: UITableViewCell {

    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var comment: PFObject! {
        didSet {
            let sender = comment["sender"] as! BravoUser
            
            senderNameLabel.text = "\(sender["firstName"]!) \(sender["lastName"]!)"
            let commentPoints = (comment["points"]! as! Int)
            if commentPoints == 0 {
                 messageLabel.text = "\(comment["message"]!)"
            } else {
                messageLabel.text = "\(comment["message"]!) +\(comment["points"]!)"
            }
            
            
            if (comment.createdAt != nil ){
                let timeSinceNow = NSDate(timeIntervalSinceNow: comment.createdAt!.timeIntervalSinceNow)
                timeLabel.text = timeSinceNow.shortTimeAgoSinceNow()
            }
            
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
