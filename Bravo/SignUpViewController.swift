//
//  SignUpViewController.swift
//  Bravo
//
//  Created by Jay Liew on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        guard inputCheck() == true else {
            print("---!!! signup input error")
            return
        }
        
        let user = PFUser()
        user.username = usernameTextField.text!
        user.password = passwordTextField.text!
        user.email = emailTextField.text!
        
        // other fields can be set just like with PFObject
        //user["phone"] = "415-392-0202"
        
        user.signUpInBackground { (succeeded: Bool, error: Error?) in
            if let error = error {
                //let errorString = error.userInfo["error"] as? NSString
                print("---!!! Parse signUpInBackground: \(error.localizedDescription)")
            } else {
                print("--- Parse signUpInBackground SUCCESS NEW USER \(self.usernameTextField.text)")
            }
            
        } // signUpInBackground
        
    } // onSignUp
    
    func inputCheck() -> Bool{
        guard firstNameTextField.text != nil && lastNameTextField.text != nil &&
            emailTextField.text != nil &&
            passwordTextField.text != nil &&
            usernameTextField.text != nil
            else {
                print("---!!! signup input nil field")
                return false }
        
        guard firstNameTextField.text?.characters.count != 0 && lastNameTextField.text?.characters.count != 0 &&
            emailTextField.text?.characters.count != 0 &&
            passwordTextField.text?.characters.count != 0 &&
            usernameTextField.text?.characters.count != 0
            else {
                print("---!!! signup input char count zero")
                return false }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
