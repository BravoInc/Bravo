//
//  AddCommentCell.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 12/4/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class AddCommentCell: UITableViewCell {

    @IBOutlet weak var addCommentButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addCommentButton.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func commentTapped(_ sender: Any) {
        print("--- Comment Tapped")
    }
    
}
