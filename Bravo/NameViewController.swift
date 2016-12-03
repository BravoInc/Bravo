//
//  NameViewController.swift
//  Bravo
//
//  Created by Jay Liew on 11/28/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
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
