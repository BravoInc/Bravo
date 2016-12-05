//
//  AddCommentCell.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 12/4/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

@objc protocol AddCommentCellDelegate {
    @objc optional func comment()
}

class AddCommentCell: UITableViewCell {

    @IBOutlet weak var addCommentButton: UIButton!
    weak var delegate: AddCommentCellDelegate?
    
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
        delegate?.comment?()
    }
    
}
