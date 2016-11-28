//
//  Comment.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/21/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class Comment: PFObject {
    class func getComments(post: PFObject, success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()) {
        let commentRelation = post.relation(forKey: "commentRelation")
        commentRelation.query().findObjectsInBackground { (comments: [PFObject]?, error: Error?) in
            if error == nil {
                success(comments as! [Comment]?)
            } else {
                failure(error)
            }
        }
    }

}
