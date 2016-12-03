//
//  SignUpPhotoViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class SignUpPhotoViewController: UIViewController {

    var signUpUser: SignUpUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
        guard signUpUser.password != nil else {
            print("---!!! MISSING PASSWORD")
            return
        }
        print("--- PASSWORD NOT NIL")

    }
    
    func miscInit(){
        UIApplication.shared.statusBarStyle = .lightContent
        
        //emailTextField.becomeFirstResponder()
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128gray888.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(SignUpPhotoViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
