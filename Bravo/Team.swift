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
    
    
    
}
