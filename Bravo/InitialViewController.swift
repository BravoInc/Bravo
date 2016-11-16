//
//  InitialViewController.swift
//  Bravo
//
//  Created by Jay Liew on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import OneSignal

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
