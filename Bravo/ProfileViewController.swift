//
//  ProfileViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, RedeemViewControllerDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var availablePointsLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var redeemedPointsLabel: UILabel!
    @IBOutlet weak var redeemedLabel: UILabel!
    @IBOutlet weak var givenPointsLabel: UILabel!
    @IBOutlet weak var givenLabel: UILabel!
    @IBOutlet weak var redeemButton: UIButton!
    
    let user = BravoUser.getLoggedInUser()
    var userSkillPoint: PFObject?
    var didRedeem: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if !didRedeem {
            loadProfile()
        } else {
            didRedeem = !didRedeem
        }
    }
    
    func loadProfile() {
        // Set label background colors
        availableLabel.backgroundColor = greenColor
        redeemedLabel.backgroundColor = purpleColor
        givenLabel.backgroundColor = orangeColor
        
        // Set button background color
        redeemButton.backgroundColor = greenColor

        // Hide Redeem button initially
        redeemButton.isHidden = true

        // Set name
        userNameLabel.text = "\(user["firstName"]!) \(user["lastName"]!)"

        // Set image view
        setImageView(imageView: userImageView, user: user)

        // Set total points available
        UserSkillPoints.getUserTotalPoints(user: user, success: {
            (userSkillPoint: PFObject?) -> () in
            let points = (userSkillPoint!["availablePoints"]! as! Int)
            self.userSkillPoint = userSkillPoint
            self.availablePointsLabel.text = "\(points)"
            self.redeemButton.isHidden = points <= 0
        }, failure: {
            (error: Error?) -> () in
            self.availablePointsLabel.text = "0"
        })
        
        // Set total points redeemed
        Reward.getRedeemedPoints(user: user, success: {
            (points: Int?) -> () in
            self.redeemedPointsLabel.text = "\(points!)"
        }, failure: {
            (error: Error?) -> () in
            self.redeemedPointsLabel.text = "0"
        })
        
        // Set total given points from the posts and comments
        var givenPoints = 0
        
        Post.getGivenPoints(user: user, success: {
            (points: Int?) -> () in
            givenPoints += points!
            self.givenPointsLabel.text = "\(givenPoints)"

            Comment.getGivenPoints(user: self.user, success: {
                (points: Int?) -> () in
                givenPoints += points!
                self.givenPointsLabel.text = "\(givenPoints)"
            }, failure: {
                (error: Error?) -> () in
                self.givenPointsLabel.text = "\(givenPoints)"
            })
        }, failure: {
            (error: Error?) -> () in
            self.givenPointsLabel.text = "\(givenPoints)"
        })
        
    }
    
    func updatePoints(redeemedPoints: Int, userSkillPoint: PFObject) {
        print ("delegate called")
        self.didRedeem = true
        let points = (userSkillPoint["availablePoints"]! as! Int)
        self.userSkillPoint = userSkillPoint
        self.availablePointsLabel.text = "\(points)"
        self.redeemButton.isHidden = points <= 0
        
        let redeemedPoints = Int(self.redeemedPointsLabel.text!)! + redeemedPoints
        self.redeemedPointsLabel.text = "\(redeemedPoints)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onLogout(_ sender: Any) {
        print ("logout pressed")
        PFUser.logOutInBackground { (error: Error?) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let introVC = storyboard.instantiateInitialViewController() as! InitialViewController
            self.present(introVC, animated: true, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let redeemVC = segue.destination as! RedeemViewController
        redeemVC.availableRewardPoints = Int(self.availablePointsLabel.text!)
        redeemVC.userSkillPoint = userSkillPoint
        redeemVC.delegate = self
    }
}
