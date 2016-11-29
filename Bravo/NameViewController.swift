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
        
        firstNameTextField.becomeFirstResponder()

        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func backBarButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
