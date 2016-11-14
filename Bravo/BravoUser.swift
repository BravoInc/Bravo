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
    
    func signUpUser(user : BravoUser, success: @escaping() -> ()){
        if (inputCheck(signUpOrLogin: false) == true){
            user["firstName"] = firstName
            user["lastName"] = lastName
            user.signUpInBackground { (succeeded: Bool, error: Error?) in
                if let error = error {
                    print("---!!! Parse signUpInBackground: \(error.localizedDescription)")
                } else {
                    print("--- Parse signUpInBackground SUCCESS NEW USER \(self.username)")
                    success()
                }
            }
        } else {
            print("---!!! signUpUser inputCheck failed")
        }
    }
    
    func logInUser(user : BravoUser, success: @escaping() -> ()){
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

}
