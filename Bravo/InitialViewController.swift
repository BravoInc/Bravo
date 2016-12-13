//
//  InitialViewController.swift
//  Bravo
//
//  Created by Jay Liew on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import UserNotifications
import TTTAttributedLabel

import Parse
import FBSDKCoreKit

class InitialViewController: UIViewController, TTTAttributedLabelDelegate {

    @IBOutlet weak var initialOuterStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if (FBSDKAccessToken.current() != nil){
            print("--- initial VC: FB ACCESS TOKEN EXISTS")
        }
        
        //UIApplication.shared.statusBarStyle = .lightContent
        
        UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
            switch setttings.soundSetting{
            case .enabled:
                print("--- push notification: enabled sound setting")
            case .disabled:
                print("--- push notification: setting has been disabled")
            case .notSupported:
                print("--- push notification: something vital went wrong here")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "hasSeenWalkthrough")
        print("--- marking that user has seen walkthrough intro in defaults")
        defaults.synchronize()        
    }

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print("--- tapped on TOS link")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "TOSNavigationViewController") as! UINavigationController
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        
    } // onCreateAccount button press
    
    @IBAction func onIntroButtonTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = storyboard.instantiateViewController(withIdentifier: "BWWalkthroughViewController") as! BWWalkthroughViewController
        let page1 = storyboard.instantiateViewController(withIdentifier: "walkthrough1")
        let page2 = storyboard.instantiateViewController(withIdentifier: "walkthrough2")
        let page3 = storyboard.instantiateViewController(withIdentifier: "walkthrough3")
        let page4 = storyboard.instantiateViewController(withIdentifier: "walkthrough4")
        walkthrough.delegate = walkthrough
        walkthrough.addViewController(vc: page1)
        walkthrough.addViewController(vc: page2)
        walkthrough.addViewController(vc: page3)
        walkthrough.addViewController(vc: page4)
        present(walkthrough, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        let vc = segue.destination as! SignUpViewController
        
        if(segue.identifier == "SignUpSegue"){
            vc.signUpOrLogin = false
            
        }else if(segue.identifier == "LoginSegue"){
            vc.signUpOrLogin = true
        }
 */
    } // prepareForSegue
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
