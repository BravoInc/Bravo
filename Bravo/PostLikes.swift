//
//  PostLikes.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/3/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class PostLikes: PFObject {
    class func createPostLike(post: PFObject, isLiked: Bool, postLikesRelation: PFRelation<PFObject>, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ())  {
        
        let newPostLike = PostLikes(className: "PostLikes")
        newPostLike["post"] = post
        
        let query = postLikesRelation.query()
        query.whereKey("post", equalTo: post)
        query.limit = 1
        
        query.findObjectsInBackground {(postLikes: [PFObject]?, error: Error?) -> Void in
            if error == nil  {
                let postLike = (postLikes?.count ?? 0 ) >= 1 ? postLikes![0] : newPostLike
                postLike["isLiked"] = isLiked

                
                success(postLike)
            } else {
                print ("Error querying for existing like posts: \(error?.localizedDescription)")
            }
        }
    }
    
    class func savePostLike(post: PFObject, isLiked: Bool, postLikesRelation: PFRelation<PFObject>, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        createPostLike(post: post, isLiked: isLiked, postLikesRelation: postLikesRelation, success: {
            (postLike: PFObject?) -> () in
            
            postLike!.saveInBackground(block: { (result : Bool, error : Error?) in
                if (error == nil) {
                    print ("-- new post like created and saved")
                    postLikesRelation.add(postLike!)
                    
                    success(postLike)
                } else {
                    print ("--failed to save post Like")
                    failure(error)
                }
            })
            
        }, failure: {
            (error: Error?) -> () in
            print("--failed to create post Like: \(error?.localizedDescription)")
        })
        
        
    }

}
