//
//  TeamCreationViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/12/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamCreationViewController: UIViewController {

    @IBOutlet weak var teamNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128white.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(SignUpPasswordViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCreateTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
        
        Team.isNewTeam(teamName: teamNameTextField.text!, success: {
            Team.createTeam(teamName: self.teamNameTextField.text!, success: { (team : PFObject) in
                print("--- team created : \(self.teamNameTextField.text!)")
                let rewardsVC = storyboard.instantiateViewController(withIdentifier: "RewardsViewController") as! RewardsViewController
                
                rewardsVC.currentTeam = team
                
                self.show(rewardsVC, sender: self)
            })

        }, failure: {
            self.showTeamErrorDialog(teamName: self.teamNameTextField.text!)
            self.teamNameTextField.text = ""
            

        })
        
    }

    func showTeamErrorDialog(teamName: String) {
        let message = "Team \(teamName) already exists."
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
