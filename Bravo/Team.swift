//
//  Team.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 11/13/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class Team: PFObject {
    
    class func isNewTeam(teamName: String, success: @escaping() -> (), failure: @escaping() -> ()){
        let query = PFQuery(className: "Team")
        query.whereKey("name", equalTo: teamName)
        query.limit = 1
        
        // fetch data asynchronously
        query.findObjectsInBackground {(teams: [PFObject]?, error: Error?) -> Void in
            if error == nil && teams?.count ?? 0 == 0 {
                success()
            } else {
                failure()
            }
        }
    }
        
    class func getAllTeams(success: @escaping([Team]?) -> (), failure: @escaping(Error?) -> ()){
        let query = PFQuery(className: "Team")
        query.order(byDescending: "createdAt")
        query.includeKey("adminUser")
        
        query.findObjectsInBackground { (teams : [PFObject]?, error : Error?) in
            if(error == nil){
                success(teams as! [Team]?)
            } else {
                failure(error)
            }
        }
    }
    
    class func getUserTeams(user: PFObject, success: @escaping([PFObject]?) -> (), failure: @escaping(Error?) -> ()){
        let teamRelation = user.relation(forKey: "teamRelation")
        let query = teamRelation.query()
        query.order(byDescending: "createdAt")
        query.includeKey("adminUser")
        query.findObjectsInBackground { (teams: [PFObject]?, error: Error?) in
            if error == nil && teams?.count ?? 0 > 0 {
                success(teams)
            } else {
                failure(error)
            }
        }
    }
    
    class func joinTeam(team: PFObject, success: @escaping() -> () ,failure: @escaping(Error?) -> ()){
        let userRelation = team.relation(forKey: "userRelation")
        userRelation.add(PFUser.current()!)
        
        team.saveInBackground { (result : Bool,error :  Error?) in
            if (error == nil ){
                print("--- Added to team")
                let query = PFQuery(className: "Team")
                query.whereKey("name", equalTo: team["name"])
                query.limit = 1
                query.findObjectsInBackground {(teams: [PFObject]?, error: Error?) -> Void in
                    if error == nil && teams?.count == 1 {
                        
                        let currentUser = PFUser.current()
                        let teamRelation = currentUser?.relation(forKey: "teamRelation")
                        teamRelation?.add((teams?[0])!)
                        
                        currentUser?.saveInBackground(block: { (result : Bool, error : Error?) in
                            if(error == nil ){
                                print("--- Saved team in current user ")
                            } else {
                                print("---!!! cannot save team in current user : \(error?.localizedDescription)")
                            }
                        })
                        success()
                    }
                }
            }
        }
    }
    
    
    class func createTeam(teamName : String, success: @escaping(PFObject) -> () ){
        let newTeam = Team(className: "Team")
        
        newTeam["name"] = teamName
        newTeam["adminUser"] = PFUser.current()
        
        let userRelation = newTeam.relation(forKey: "userRelation")
        userRelation.add(PFUser.current()!)
        
        
        newTeam.saveInBackground { (result : Bool, error : Error?) in
            if (error == nil){
                let query = PFQuery(className: "Team")
                query.whereKey("name", equalTo: teamName)
                query.limit = 1
                query.findObjectsInBackground {(teams: [PFObject]?, error: Error?) -> Void in
                    if error == nil && teams?.count == 1 {
                        
                        let currentUser = PFUser.current()
                        let teamRelation = currentUser?.relation(forKey: "teamRelation")
                        teamRelation?.add((teams?[0])!)
                        
                        currentUser?.saveInBackground(block: { (result : Bool, error : Error?) in
                            if(error == nil ){
                                print("--- Saved team in current user ")
                            } else {
                                print("---!!! cannot save team in current user : \(error?.localizedDescription)")
                            }
                        })
                        success((teams?[0])!)
                    }
                }
            }
        }
    }
}
