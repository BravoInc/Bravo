//
//  SignUpPasswordViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class SignUpPasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    
    var signUpUser: SignUpUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
        guard signUpUser.email != nil else {
            print("---!!! MISSING EMAIL")
            return
        }
        print("--- \(signUpUser.email)")

    }

    func miscInit(){
        UIApplication.shared.statusBarStyle = .lightContent
        passwordTextField.becomeFirstResponder()
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128gray888.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(SignUpPasswordViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @IBAction func onNextButtonPress(_ sender: Any) {
        signUpUser.password = passwordTextField.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNav = segue.destination as! UINavigationController
        let destinationVC = destinationNav.topViewController as! SignUpPhotoViewController
        destinationVC.signUpUser = self.signUpUser
    }

    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
