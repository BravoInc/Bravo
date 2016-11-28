//
//  PostComposeViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/26/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class PostComposeViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func createPost(_ sender: Any) {
        
    }
    

    @IBAction func cancelPost(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editingBegin(_ sender: Any) {
        presentSelectionController()
    }
    
    func presentSelectionController() {
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        
        let selectionNavController = storyboard.instantiateViewController(withIdentifier: "SelectionNavigationController") as! UINavigationController
        
        let selectionVC = storyboard.instantiateViewController(withIdentifier: "SelectionViewController") as! SelectionViewController
        //rewardVC.currentTeam = self.currentTeam
        //rewardVC.delegate = self
        selectionNavController.setViewControllers([selectionVC], animated: true)
        self.present(selectionNavController, animated: true, completion: nil)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
