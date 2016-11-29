//
//  UserPoints.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/21/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class UserPoints: PFObject {
    class func createUserPoints(user: PFUser, points: Int, userPointsRelation: PFRelation<PFObject>, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        let newUserPoint = UserPoints(className: "UserPoints")
        newUserPoint["user"] = user
        newUserPoint["points"] = 0
        
        let query = userPointsRelation.query()
        query.whereKey("user", equalTo: user)
        query.limit = 1
        
        query.findObjectsInBackground {(userPoints: [PFObject]?, error: Error?) -> Void in
            if error == nil  {
                let userPoint = (userPoints?.count ?? 0) >= 1 ? userPoints![0] : newUserPoint
                userPoint["points"] = (userPoint["points"]! as! Int) + points
                
                success(userPoint)
            } else {
                print ("Error getting userPoint count: \(error?.localizedDescription)")
            }
        }
        
    }
    
    class func saveUserPoints(user: PFUser, points: Int, userPointsRelation: PFRelation<PFObject>, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        createUserPoints(user: user, points: points, userPointsRelation: userPointsRelation, success: {
            (userPoints: PFObject?) -> () in
            userPoints!.saveInBackground(block: { (result : Bool, error : Error?)in
                if (error == nil) {
                    userPointsRelation.add(userPoints!)
                    print ("-- new user pointer created and saved")
                    success(userPoints)
                } else {
                    print ("--failed to save user point")
                    failure(error)
                }

            })            
        }, failure: {
            (error: Error?) -> () in
            print ("--failed to create user point: \(error?.localizedDescription)")
        })
        
        
        
    }
}
