//
//  CommentHeaderCell.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 12/7/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class CommentHeaderCell: UITableViewCell {
    
    @IBOutlet weak var recipientNameLabel: UILabel!
    
    var team : PFObject!
    var post: PFObject!{
        didSet{
            let sender = post["sender"] as! BravoUser
            let recipient = post["recipient"] as! BravoUser
            
            postHeaderTextCreate(recipient: recipient, sender: sender, team : team,headerLabel: recipientNameLabel)
            
            
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
