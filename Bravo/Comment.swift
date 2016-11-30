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
    class func createComment(post: PFObject, message: String, points: Int) -> PFObject {
        let newComment = Comment(className: "Comment")
        
        newComment["sender"] = BravoUser.getLoggedInUser()
        newComment["message"] = message
        newComment["points"] = points
        newComment["post"] = post
        
        return newComment
    }

    class func saveComment(comment: PFObject, post: PFObject, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()){
        
        comment.saveInBackground { (result : Bool, error : Error?) in
            if (error == nil){
                print ("-- new comment created")
                let commentRelation = post.relation(forKey: "commentRelation")
                commentRelation.add(comment)
                
                post.saveInBackground(block: { (result : Bool, error : Error?) in
                    if(error == nil ){
                        print("--- Saved comment in its post ")
                        // Run success method after saving the relation
                        success(comment)
                    } else {
                        print("---!!! cannot save comment in its post : \(error?.localizedDescription)")
                    }
                })
            } else {
                print ("-- comment creation failed")
                failure(error)
            }
        }
    }
    
    class func getComments(post: PFObject, success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()) {
        let commentRelation = post.relation(forKey: "commentRelation")
        let query = commentRelation.query()
        query.order(byAscending: "createdAt")
        query.includeKey("sender")

        query.findObjectsInBackground { (comments: [PFObject]?, error: Error?) in
            if error == nil {
                success(comments as! [Comment]?)
            } else {
                failure(error)
            }
        }
    }

}
