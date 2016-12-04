//
//  Post.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/21/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class Post: PFObject {
    
    class func createPost(recipient : PFUser, message: String, skill: String, points: Int, team: PFObject) -> PFObject {
        let newPost = Post(className: "Post")
        
        newPost["sender"] = BravoUser.getLoggedInUser()
        newPost["recipient"] = recipient
        newPost["message"] = message
        newPost["skill"] = skill
        newPost["points"] = points
        newPost["team"] = team
        newPost["likeCount"] = 0
        newPost["commentCount"] = 0

        return newPost
    }
    
    class func savePost(post: PFObject, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()){
        
        post.saveInBackground { (result : Bool, error : Error?) in
            if (error == nil){
                print ("-- new post created")
                success(post)
            } else {
                print ("-- post creation failed")
                failure(error)
            }
        }
    }
    
    class func getAllPosts(success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "Post")
        query.order(byDescending: "createdAt")
        query.includeKey("sender")
        query.includeKey("recipient")
        
        
        query.findObjectsInBackground { (posts : [PFObject]?, error : Error?) in
            if(error == nil){
                success(posts as! [Post]?)
            } else {
                failure(error)
            }
        }
    }
    
    class func getGivenPoints(user: PFUser, success: @escaping(Int?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "Post")
        query.whereKey("sender", equalTo: user)
        
        query.findObjectsInBackground {(posts: [PFObject]?, error: Error?) -> Void in
            if error == nil && posts?.count ?? 0 > 0 {
                let pointsGiven = posts!.reduce(0, {
                    $0 + ($1["points"]! as! Int)
                })
                success(pointsGiven)
            } else {
                print ("Error getting given points for the posts: \(error?.localizedDescription)")
                failure(error)
            }
        }
    }
    
    class func updateLikeCount(post: PFObject, increment: Bool, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        post.incrementKey("likeCount", byAmount: increment ? 1 : -1)
   
        
        post.saveInBackground { (result : Bool, error : Error?) in
            if (error == nil){
                print ("-- post like count updated")
                success(post)
            } else {
                print ("-- post like count update failed")
                failure(error)
            }
        }
    }
    
    class func countComments(post: PFObject, success: @escaping(Int?) -> (), failure: @escaping(Error?) -> ()) {
        let commentRelation = post.relation(forKey: "commentRelation")
        commentRelation.query().countObjectsInBackground { (count:Int32, error: Error?) in
            if error == nil {
                print ("post has \(Int(count)) comments")
                post["commentCount"] = Int(count)
                post.saveInBackground()
                success(Int(count))
            } else {
                failure(error)
            }
        }
    }

}

