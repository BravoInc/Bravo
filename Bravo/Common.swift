//
//  Common.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/1/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import Foundation
import Parse

func setImageView(imageView: UIImageView, user: PFUser) {
    // Setting image view
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = true
    
    imageView.image = UIImage(named: "noProfilePic")
    let image = user["profileImage"] as? PFFile
    image?.getDataInBackground(block: { (imageData: Data?, error: Error?) in
        if error == nil && imageData != nil {
            imageView.image = UIImage(data:imageData!)
        }
    })
}


