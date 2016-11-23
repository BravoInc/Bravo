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
    
    
    class func createReward(team : PFObject, rewardName : String, rewardPoints : Int, isActive: Bool) -> PFObject {
        let reward = PFObject(className: "Reward")
        reward["name"] = rewardName
        reward["points"] = rewardPoints
        reward["team"] = team
        reward["isActive"] = isActive

        return reward
    }
    
    class func createRewards(rewards: [PFObject], success: @escaping() -> (), failure: @escaping(Error?) -> () ){

        PFObject.saveAll(inBackground: rewards, block: { (result : Bool, error :  Error?) in
            if (error == nil ){
                print("--- Created Reward after save in background:")                
            } else {
                failure(error)
            }
        })
    }

}
