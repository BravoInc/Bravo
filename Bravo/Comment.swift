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
                post.incrementKey("commentCount", byAmount: 1)
                
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

    class func getGivenPoints(user: PFUser, success: @escaping(Int?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "Comment")
        query.whereKey("sender", equalTo: user)
        
        query.findObjectsInBackground {(comments: [PFObject]?, error: Error?) -> Void in
            if error == nil && comments?.count ?? 0 > 0 {
                let pointsGiven = comments!.reduce(0, {
                    $0 + ($1["points"]! as! Int)
                })
                success(pointsGiven)
            } else {
                print ("Error getting given points for the comments: \(error?.localizedDescription)")
                failure(error)
            }
        }
    }
}
