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
    
    class func createUserSkillPoints(user: PFUser, skill: String, points: Int, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        let newUserSkillPoint = UserSkillPoints(className: "UserSkillPoints")
        newUserSkillPoint["user"] = user
        newUserSkillPoint["totalPoints"] = 0
        newUserSkillPoint["availablePoints"] = 0
        
        let query = PFQuery(className: "UserSkillPoints")
        query.whereKey("user", equalTo: user)
        query.limit = 1
        
        query.findObjectsInBackground {(userSkillPoints: [PFObject]?, error: Error?) -> Void in
            if error == nil  {
                let userSkillPoint = (userSkillPoints?.count)! >= 1 ? userSkillPoints![0] : newUserSkillPoint
                userSkillPoint["totalPoints"] = (userSkillPoint["totalPoints"]! as! Int) + points
                userSkillPoint["availablePoints"] = (userSkillPoint["availablePoints"]! as! Int) + points
                userSkillPoint.addUniqueObject(skill, forKey: "skills")

                success(userSkillPoint)
            } else {
                print ("Error getting skill count: \(error?.localizedDescription)")
            }
        }
        
        
    }
    
    class func saveUserSkillPoints(user: PFUser, skillName: String, points: Int, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        createUserSkillPoints(user: user, skill: skillName, points: points, success: {
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
    
    class func getUserPoints(success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "UserSkillPoints")
        query.includeKey("user")
        query.order(byDescending: "totalPoints")
        
        query.findObjectsInBackground { (userSkillPoints : [PFObject]?, error : Error?) in
            if(error == nil){
                print ("--user skill points data: \(userSkillPoints)")
                success(userSkillPoints as! [UserSkillPoints]?)
            } else {
                failure(error)
            }
        }
    }
    
    class func getUserTotalPoints(user: PFUser, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "UserSkillPoints")
        query.whereKey("user", equalTo: user)
        query.limit = 1
        
        query.findObjectsInBackground {(userSkillPoints: [PFObject]?, error: Error?) -> Void in
            if error == nil && userSkillPoints?.count == 1 {
                success(userSkillPoints![0])
            } else {
                print ("Error getting skill count: \(error?.localizedDescription)")
                failure(error)
            }
        }
    }
    
    class func updateUserPoints(userSkillPoint: PFObject, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()){
        userSkillPoint.saveInBackground(block: { (result : Bool, error : Error?) in
            if(error == nil ){
                print("--- Updated user skill point successfully: \(userSkillPoint) ")
                success(userSkillPoint)
            } else {
                print("---!!! cannot update user skill point : \(error?.localizedDescription)")
                failure(error)
            }
        })
    }
}
