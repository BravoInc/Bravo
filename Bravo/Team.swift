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
    
    
    class func createTeam(teamName : String, success: @escaping() -> () ){
        let newTeam = PFObject(className: "Team")
        let teamUsers = PFObject(className: "TeamUsers")
        
        newTeam["name"] = teamName
        newTeam["adminUser"] = PFUser.current()
        teamUsers["user"] = PFUser.current()
        newTeam["users"] = teamUsers

        newTeam.saveInBackground { (result : Bool, error : Error?) in
            if (error == nil){
                success()
            }
        }
    }
}
