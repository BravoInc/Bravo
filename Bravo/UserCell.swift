//
//  UserCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/27/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    
    var user: PFUser! {
        didSet {
            userFullNameLabel.text = "\(user["firstName"]!) \(user["lastName"]!)"
            userNameLabel.text = "@\(user["username"]!)"
            
            // Setting user image view
            setImageView(imageView: profileImageView, user: user)
        }
    }
    var isChecked: Bool = false
    
    func setImageViews() {
        selectionImageView.image = UIImage(named: isChecked ? "selectedCircle" : "borderCircle")
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
