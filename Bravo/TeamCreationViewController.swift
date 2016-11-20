//
//  TeamCreationViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class TeamCreationViewController: UIViewController {

    @IBOutlet weak var companyNameTextField: UITextField!
    @IBOutlet weak var teamNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
        
        Team.teamExists(teamName: teamNameTextField.text!, success: {
            Team.createTeam(teamName: self.teamNameTextField.text!, companyName: self.companyNameTextField.text!, success: {
                print("--- team created : \(self.teamNameTextField.text!)")
                let rewardsVC = storyboard.instantiateViewController(withIdentifier: "RewardsViewController")
                self.show(rewardsVC, sender: self)
            })

        }, failure: {
            print ("Team \(self.teamNameTextField.text!) already exists")
            

        })
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
