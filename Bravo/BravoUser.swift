//
//  BravoUser.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class BravoUser: PFUser {
    var firstName : String?
    var lastName : String?
    
    func signUpUser( success: @escaping() -> ()){
        self["firstName"] = firstName
        self["lastName"] = lastName
//        self["email"] = tmpEmail
//        self["profileImage"] = profileImage
        
        self.signUpInBackground { (succeeded: Bool, error: Error?) in
            if let error = error {
                print("---!!! Parse signUpInBackground: \(error.localizedDescription)")
            } else {
                print("--- Parse signUpInBackground SUCCESS NEW USER \(self.username)")
                success()
            }
            
        } // signUpInBackground
        
    } // signUpUser
    
    func logInUser(success: @escaping() -> ()){
        
        if(inputCheck(signUpOrLogin: true) == true){
            PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (loggedInUser : PFUser?, error : Error?) in
                if (error != nil){
                    print("---!!! logInUser failed")
                } else {
                    success()
                }
            })
        } else {
            print("---!!! logInUser inputCheck failed")
        }
    }
    
    func inputCheck(signUpOrLogin : Bool) -> Bool{
        if(signUpOrLogin == false){
            
            guard firstName != nil &&
                lastName != nil &&
                email != nil
                else {
                    print("---!!! signup input nil field")
                    return false }
            
            guard firstName?.characters.count != 0 &&
                lastName?.characters.count != 0 &&
                email?.characters.count != 0
                else {
                    print("---!!! signup input char count zero")
                    return false }
        } // false == signup
        
        guard
            password != nil &&
                username != nil
            else {
                print("---!!! signup input nil field")
                return false }
        
        guard
            password?.characters.count != 0 &&
                username?.characters.count != 0
            else {
                print("---!!! signup input char count zero")
                return false }
        
        return true
    }
    
    class func getLoggedInUser() -> BravoUser{
        return PFUser.current() as! BravoUser
    }

    class func getTeamUsers(team: PFObject, success: @escaping([PFUser]?) -> (), failure: @escaping(Error?) -> ()){
        
        let userRelation = team.relation(forKey: "userRelation")
        userRelation.query().findObjectsInBackground { (users: [PFObject]?, error: Error?) in
            if error == nil {
                success(users as! [PFUser]?)
            } else {
                failure(error)
            }
        }
    }
    

}
