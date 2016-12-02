//
//  ProfileViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfile()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        loadProfile()
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
            (points: Int?) -> () in
            self.availablePointsLabel.text = "\(points!)"
            self.redeemButton.isHidden = points! <= 0
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
