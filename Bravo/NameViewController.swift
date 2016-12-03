//
//  NameViewController.swift
//  Bravo
//
//  Created by Jay Liew on 11/28/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

struct SignUpUser {
    var firstName: String?
    var lastName: String?
    var username: String?
    var email: String?
    var password: String?
    var photo: UIImage?
}

class NameViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var signUpUser = SignUpUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
    }
    
    @IBAction func onTap(_ sender: Any) {
        signUpUser.firstName = firstNameTextField.text
        signUpUser.lastName = lastNameTextField.text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNav = segue.destination as! UINavigationController
        let destinationVC = destinationNav.topViewController as! SignUpEmailViewController
        destinationVC.signUpUser = self.signUpUser
    }
    
    func miscInit(){
        UIApplication.shared.statusBarStyle = .lightContent
        firstNameTextField.becomeFirstResponder()
        transparentNavBar()
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128gray888.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(NameViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
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
