//
//  UserSkillPoints.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/28/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

/*
 Helper class to save skill points per user. To get around parse restriction on
 logged in user.
 */
class UserSkillPoints: PFObject {
    
    class func createUserSkillPoints(user: PFUser, points: Int, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        let userSkillPoint = UserSkillPoints(className: "UserSkillPoints")
        userSkillPoint["user"] = user
        
        let query = PFQuery(className: "UserSkillPoints")
        query.whereKey("user", equalTo: user)
        query.limit = 1
        
        query.findObjectsInBackground {(userSkillPoints: [PFObject]?, error: Error?) -> Void in
            if error == nil  {
                success((userSkillPoints?.count)! >= 1 ? userSkillPoints?[0] : userSkillPoint)
            } else {
                print ("Error getting skill count: \(error?.localizedDescription)")
            }
        }
        
        
    }
    
    class func saveUserSkillPoints(user: PFUser, skillName: String, points: Int, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        createUserSkillPoints(user: user, points: points, success: {
            (userSkillPoint: PFObject?) -> () in
            
            let skillPointsRelation = userSkillPoint!.relation(forKey: "skillPointsRelation")
            
            SkillPoints.saveSkillPoints(skillName: skillName, points: points, skillPointsRelation: skillPointsRelation, success: {(skillPoints: PFObject?) in
                
                userSkillPoint!.saveInBackground(block: { (result : Bool, error : Error?) in
                    if(error == nil ){
                        print("--- Added skill points in provided user: \(user) ")
                        success(userSkillPoint)
                    } else {
                        print("---!!! cannot save skill in provided user : \(error?.localizedDescription)")
                        failure(error)
                    }
                })
            }, failure: {(error: Error?) in
                print ("--failed to save skill points: \(error?.localizedDescription)")
            })
        }, failure: {
            (error: Error?) -> () in
            print("--failed to query and create userSkillPoint")
        })
        
        
        
        
        
    }
    
}
