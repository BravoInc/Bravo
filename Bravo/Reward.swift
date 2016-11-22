//
//  Reward.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 11/20/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class Reward: PFObject {
    
    
    class func createReward(team : PFObject,rewardName : String, rewardPoints : Int, success: @escaping() -> (), failure: @escaping(Error?) -> () ){
        let reward = PFObject(className: "Reward")
        reward["name"] = rewardName
        reward["points"] = rewardPoints
        reward["team"] = team
        
        reward.saveInBackground { (result : Bool, error :  Error?) in
            if (error == nil ){
                print("--- Created Reward Id after save in background: \(reward.objectId)")
                print("--- Created Reward : \(rewardName)")
                
                let rewardRelation = team.relation(forKey: "rewardRelation")
                rewardRelation.add(reward)
                team.saveInBackground(block: { (result : Bool, error : Error?) in
                    if(error == nil){
                        success()
                    }else {
                        failure(error)
                    }
                })
            } else {
                failure(error)
            }
        }
    }
}
