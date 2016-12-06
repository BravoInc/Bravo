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

class InitialViewController: UIViewController, TTTAttributedLabelDelegate {

    @IBOutlet weak var disclaimer: TTTAttributedLabel!
    @IBOutlet weak var initialOuterStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        //UIApplication.shared.statusBarStyle = .lightContent
        
        self.disclaimer.delegate = self
        
        let TOS = "Terms Of Service"
        let disclaimerText = "By signing up, I agree to Bravo's \(TOS)"
        self.disclaimer.text = disclaimerText
        
        self.disclaimer.linkAttributes = [
            NSForegroundColorAttributeName: customGray,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        
        self.disclaimer.activeLinkAttributes = [NSForegroundColorAttributeName: customGreen,]
        
        let tmpString = disclaimerText as NSString
        let range = tmpString.range(of: TOS)
        let url = URL(string: "http://www.jayliew.com")
        
        self.disclaimer.addLink(to: url!, with: (range as NSRange))
        
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

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        print("--- tapped on TOS link")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "TOSNavigationViewController") as! UINavigationController
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        
    } // onCreateAccount button press
    
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
