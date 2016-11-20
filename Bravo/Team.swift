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
    var teamID : String?
    var name : String?
    var adminUser : BravoUser?
    var users : [BravoUser]?
    var company : Company?
    
    class func teamExists(teamName: String, success: @escaping() -> (), failure: @escaping() -> ()){
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
    
    class func createTeam(teamName : String, companyName: String, success: @escaping() -> () ){
        let newTeam = PFObject(className: "Team")
        let teamUsers = PFObject(className: "TeamUsers")
        
        newTeam["name"] = teamName
        newTeam["adminUser"] = PFUser.current()
        teamUsers["user"] = PFUser.current()
        newTeam["users"] = teamUsers
        
        newTeam.saveInBackground { (result : Bool, error : Error?) in
            if (error == nil){
                let query = PFQuery(className: "Team")
                query.whereKey("name", equalTo: teamName)
                query.limit = 1
                query.findObjectsInBackground {(teams: [PFObject]?, error: Error?) -> Void in
                    if error == nil && teams?.count == 1 {
                        
                        let userTeams = PFObject(className: "UserTeams")
                        userTeams["team"] = teams?[0]
                        
                        let currentUser = PFUser.current()
                        currentUser?["teams"] = userTeams
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
}
