//
//  LoginViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    let user = BravoUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        user.logInUser(success: {
            print("--- LOGIN success \(self.usernameTextField.text)")
            
            
            let storyBoard = UIStoryboard(name: "Activity", bundle: nil)
            
            let timelineNavigationController = storyBoard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
            let timelineViewController = timelineNavigationController.topViewController as! TimelineViewController
            timelineNavigationController.tabBarItem.title = "Timeline"
            //timelineNavigationController.tabBarItem.image = UIImage(named: "NoImage")
            
            
            let storyBoardTC = UIStoryboard(name: "TeamCreation", bundle: nil)
            let teamNavigationController = storyBoardTC.instantiateViewController(withIdentifier: "TeamNavigationController") as! UINavigationController
            //let teamViewController = teamNavigationController.topViewController as! TeamViewController
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
