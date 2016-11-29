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
    
    class func createPost(recipient : PFUser, message: String, points: Int, team: PFObject) -> PFObject {
        let newPost = Post(className: "Post")
        
        newPost["sender"] = BravoUser.getLoggedInUser()
        newPost["recipient"] = recipient
        newPost["message"] = message
        newPost["points"] = points
        newPost["team"] = team

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

}

