//
//  SkillPoints.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/21/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class SkillPoints: PFObject {

    class func createSkillPoints(skillName: String, points: Int, skillPointsRelation: PFRelation<PFObject>, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ())  {

        let newSkillPoint = SkillPoints(className: "SkillPoints")
        newSkillPoint["skill"] = skillName
        newSkillPoint["points"] = 0
        
        let query = skillPointsRelation.query()
        query.whereKey("skill", equalTo: skillName)
        query.limit = 1

        query.findObjectsInBackground {(skillPoints: [PFObject]?, error: Error?) -> Void in
            if error == nil  {
                let skillPoint = (skillPoints?.count ?? 0 ) >= 1 ? skillPoints![0] : newSkillPoint
                skillPoint["points"] = (skillPoint["points"]! as! Int) + points
                
                success(skillPoint)
            } else {
                print ("Error getting skillPoint count: \(error?.localizedDescription)")
            }
        }
    }
    
    class func saveSkillPoints(skillName: String, points: Int, skillPointsRelation: PFRelation<PFObject>, success: @escaping(PFObject?) -> (), failure: @escaping(Error?) -> ()) {
        
        createSkillPoints(skillName: skillName, points: points, skillPointsRelation: skillPointsRelation, success: {
            (skillPoints: PFObject?) -> () in
            
            skillPoints!.saveInBackground(block: { (result : Bool, error : Error?) in
                if (error == nil) {
                    print ("-- new skill pointer created and saved")
                    skillPointsRelation.add(skillPoints!)
                    
                    success(skillPoints)
                } else {
                    print ("--failed to save skill point")
                    failure(error)
                }
            })

        }, failure: {
            (error: Error?) -> () in
            print("--failed to create skill point: \(error?.localizedDescription)")
        })

        
    }

}
