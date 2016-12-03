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
        reward["isClaimed"] = false
        reward["points"] = rewardPoints
        reward["team"] = team
        reward["isActive"] = isActive

        return reward
    }
    
    class func createRewards(rewards: [PFObject], team : PFObject,success: @escaping() -> (), failure: @escaping(Error?) -> () ){

        PFObject.saveAll(inBackground: rewards, block: { (result : Bool, error :  Error?) in
            if (error == nil ){
                print("--- Created Reward after save in background:")
                for reward in rewards{
                    let rewardRelation = team.relation(forKey: "rewardRelation")
                    rewardRelation.add(reward)
                    team.saveInBackground(block: { (result : Bool, error : Error?) in
                        if(error == nil){
                            print("--- added relation for reward")
                        }
                    })
                    
                }
                
            } else {
                failure(error)
            }
        })
    }
    
    class func getRedeemedPoints(user: PFUser, success: @escaping(Int?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "Reward")
        query.whereKey("claimedBy", equalTo: user)
        
        query.findObjectsInBackground {(rewards: [PFObject]?, error: Error?) -> Void in
            if error == nil && rewards?.count ?? 0 > 0 {
                let pointsRedeemed = rewards!.reduce(0, {
                  $0 + ($1["totalPoints"]! as! Int)
                })
                success(pointsRedeemed)
            } else {
                print ("Error getting redeemed rewards: \(error?.localizedDescription)")
                failure(error)
            }
        }
    }

}
