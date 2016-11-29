//
//  Skills.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/21/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse
class Skills: PFObject {
    
    class func createSkill(skillName: String, success: @escaping(PFObject?) -> () ,failure: @escaping(Error?) -> ()){
        let newSkill = Skills(className: "Skills")
        newSkill["skill"] = skillName
        
        let query = PFQuery(className: "Skills")
        query.whereKey("skill", equalTo: skillName)
        query.limit = 1

        query.findObjectsInBackground {(skills: [PFObject]?, error: Error?) -> Void in
            if error == nil  {
                success((skills?.count)! >= 1 ? skills?[0] : newSkill)
            } else {
                print ("Error getting skill count: \(error?.localizedDescription)")
            }
        }
    }
    
    class func saveSkill(skillName: String, user: PFUser, points: Int, success: @escaping(PFObject?) -> () ,failure: @escaping(Error?) -> ()) {
        
        
        createSkill(skillName: skillName, success: {(skill: PFObject?) -> () in
            let userPointsRelation = skill!.relation(forKey: "userPointsRelation")
            
            UserPoints.saveUserPoints(user: user, points: points, userPointsRelation: userPointsRelation, success: {(userPoints: PFObject?) in
                
                // Saving skill
                skill!.saveInBackground { (result : Bool, error : Error?) in
                    if (error == nil) {
                        print ("-- new skill created and saved")
                        success(skill)
                    } else {
                        print ("--failed to save skill")
                        failure(error)
                    }
                }
                
            }, failure: {(error: Error?) in
                print ("-- error adding user points")
            })
        }, failure: {
            (error: Error?) -> () in
            print ("-- error querying and creating skill")
        })


    }
}
