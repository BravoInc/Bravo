//
//  SignUpEmailViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class SignUpEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    var signUpUser: SignUpUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
        guard signUpUser.firstName != nil && signUpUser.lastName != nil else {
            print("---!!! MISSING FIRST AND LAST NAME")
            return
        }
        print("--- \(signUpUser.firstName) + \(signUpUser.lastName)")
    }

    func miscInit(){
        UIApplication.shared.statusBarStyle = .lightContent
        emailTextField.becomeFirstResponder()
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128gray888.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(SignUpEmailViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNav = segue.destination as! UINavigationController
        let destinationVC = destinationNav.topViewController as! SignUpPasswordViewController
        destinationVC.signUpUser = self.signUpUser
    }

    @IBAction func onNextButtonPress(_ sender: Any) {
        signUpUser.email = emailTextField.text
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
