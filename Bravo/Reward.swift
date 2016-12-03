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
                  $0 + ($1["points"]! as! Int)
                })
                success(pointsRedeemed)
            } else {
                print ("Error getting redeemed rewards: \(error?.localizedDescription)")
                failure(error)
            }
        }
    }
    
    class func getAvailableRewards(user: PFUser, success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()) {
        Team.getUserTeams(user: user, success: {
            (teams: [PFObject]?) -> () in
                let query = PFQuery(className: "Reward")
                query.whereKey("isClaimed", equalTo: false)
                query.whereKey("team", containedIn: teams!)
                
                query.findObjectsInBackground {(rewards: [PFObject]?, error: Error?) -> Void in
                    if error == nil && rewards?.count ?? 0 > 0 {
                        success(rewards)
                    } else {
                        print ("Error getting available rewards: \(error?.localizedDescription)")
                        failure(error)
                    }
                }
        }, failure: {
            (error: Error?) -> () in
            print ("Failed to get user teams. Skipping rewards retrieval: \(error?.localizedDescription)")
            failure(error)
        })
    }

    class func updateRewards(rewards: [PFObject], success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()) {
        PFObject.saveAll(inBackground: rewards, block: { (result : Bool, error :  Error?) in
            if (error == nil ){
                print("--- Updated rewards successfully in background:")
                success(rewards)
            } else {
                print ("-- Error updating rewards. \(error?.localizedDescription)")
                failure(error)
            }
        })
    }
}
