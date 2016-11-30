//
//  CommentHeaderView.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/29/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class CommentHeaderView: UIView {

    /*@IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var recipientImageView: UIImageView!
 
    var post: PFObject! {
        didSet {
            print ("--Comment Header View Set")
            // Image Views
            //let sender = post["sender"] as! BravoUser
            let recipient = post["recipient"] as! BravoUser
            
            recipientNameLabel.text = "\(recipient["firstName"]!) \(recipient["lastName"]!)"
            messageLabel.text = "+\(post["points"]!) for \(post["message"]!)"
        }
    }
    */
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CommentHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }


}
