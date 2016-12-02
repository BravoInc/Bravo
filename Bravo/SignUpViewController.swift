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
    
    @IBOutlet weak var CTALabel: UILabel!
    @IBOutlet weak var CTAButton: UIButton!
    
    var signUpOrLogin = true // false == signup, true == login
    let user = BravoUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(signUpOrLogin == true){
            CTALabel.text = "Please Login"
            CTAButton.setTitle("Login", for: UIControlState.normal)
            firstNameTextField.isHidden = true
            lastNameTextField.isHidden = true
            emailTextField.isHidden = true
        }
        
    } // viewDidLoad
    
    @IBAction func onSignUp(_ sender: Any) {
        guard inputCheck() == true else {
            print("---!!! signup input error")
            return
        }
        
        if(signUpOrLogin == false){ // signup
            user.username = usernameTextField.text!
            user.password = passwordTextField.text!
            user.firstName = firstNameTextField.text!
            user.lastName = lastNameTextField.text!
            user.email = emailTextField.text!
            
            user.signUpUser(success: {
                self.onLogin()
            })
            
        }else{ // login only
            user.username = usernameTextField.text!
            user.password = passwordTextField.text!
            onLogin()
        }
        
    } // onSignUp
    
    func onLogin(){
        user.logInUser(success: {
            print("--- LOGIN success \(self.usernameTextField.text)")
            
            
            let storyBoard = UIStoryboard(name: "Activity", bundle: nil)
            
            let timelineNavigationController = storyBoard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
            let timelineViewController = timelineNavigationController.topViewController as! TimelineViewController
            timelineNavigationController.tabBarItem.title = "Timeline"
            //timelineNavigationController.tabBarItem.image = UIImage(named: "NoImage")

            let teamNavigationController = storyBoard.instantiateViewController(withIdentifier: "TeamNavigationController") as! UINavigationController
            let teamViewController = teamNavigationController.topViewController as! TeamViewController
            teamNavigationController.tabBarItem.title = "Teams"
            //teamNavigationController.tabBarItem.image = UIImage(named: "NoImage")

            let leaderboardNavigationController = storyBoard.instantiateViewController(withIdentifier: "LeaderboardNavigationController") as! UINavigationController
            let leaderboardViewController = leaderboardNavigationController.topViewController as! LeaderboardViewController
            leaderboardNavigationController.tabBarItem.title = "Leaderboard"
            //leaderboardNavigationController.tabBarItem.image = UIImage(named: "NoImage")

            let profileNavigationController = storyBoard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
            let profileViewController = profileNavigationController.topViewController as! ProfileViewController
            profileNavigationController.tabBarItem.title = "Profile"
            //profileNavigationController.tabBarItem.image = UIImage(named: "NoImage")

            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [timelineNavigationController, teamNavigationController, leaderboardNavigationController, profileNavigationController]
            //tabBarController.selectedViewController = teamNavigationController

            self.present(tabBarController, animated: true, completion: nil)
            
            

        })
    }
    
    func inputCheck() -> Bool{
        
        if(signUpOrLogin == false){
            
            guard firstNameTextField.text != nil &&
                lastNameTextField.text != nil &&
                emailTextField.text != nil
                else {
                    print("---!!! signup input nil field")
                    return false }
            
            guard firstNameTextField.text?.characters.count != 0 &&
                lastNameTextField.text?.characters.count != 0 &&
                emailTextField.text?.characters.count != 0
                else {
                    print("---!!! signup input char count zero")
                    return false }
        } // false == signup
        
        guard
            passwordTextField.text != nil &&
                usernameTextField.text != nil
            else {
                print("---!!! signup input nil field")
                return false }
        
        guard
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
