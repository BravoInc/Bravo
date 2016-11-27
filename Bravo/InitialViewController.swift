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

class InitialViewController: UIViewController {

    @IBOutlet weak var disclaimer: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let TOS = "Terms Of Service"
        let disclaimerText = "By signing up, I agree to Bravo's \(TOS)"
        self.disclaimer.text = disclaimerText
        
        self.disclaimer.linkAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        
        self.disclaimer.activeLinkAttributes = [NSForegroundColorAttributeName: UIColor.green,]
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SignUpViewController
        
        if(segue.identifier == "SignUpSegue"){
            vc.signUpOrLogin = false
            
        }else if(segue.identifier == "LoginSegue"){
            vc.signUpOrLogin = true
        }
    }
}
