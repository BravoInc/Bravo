//
//  ProfileViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, RedeemViewControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var availablePointsLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var redeemedPointsLabel: UILabel!
    @IBOutlet weak var redeemedLabel: UILabel!
    @IBOutlet weak var givenPointsLabel: UILabel!
    @IBOutlet weak var givenLabel: UILabel!
    @IBOutlet weak var redeemButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var availablePointView: UIView!
    @IBOutlet weak var redeemedPointView: UIView!
    
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var givenPointView: UIView!
    
    
    var user: PFUser = BravoUser.getLoggedInUser()
    var userSkillPoint: PFObject?
    var didRedeem: Bool = false
    var skills: String = ""
    
    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        if self.user.objectId! != BravoUser.getLoggedInUser().objectId! {
            self.navigationItem.rightBarButtonItem = nil
        }
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(loadProfile), for: UIControlEvents.valueChanged)
        scrollView.insertSubview(progressControl.refreshControl, at: 0)

        loadProfile(refreshControl: progressControl.refreshControl)
        // Do any additional setup after loading the view.
    }
    

    
    func loadProfile(refreshControl: UIRefreshControl) {
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }

        // Set label background colors
        redeemedLabel.backgroundColor = purpleColor
        givenLabel.backgroundColor = orangeColor
        
        // Set button background color
        redeemButton.backgroundColor = greenColor

        // Hide Redeem button initially
        redeemButton.isEnabled = false

        // Set name
        if user["firstName"] != nil && user["lastName"] != nil {
            userNameLabel.text = "\(user["firstName"]!) \(user["lastName"]!)"
        }

        // Set image view
        setImageView(imageView: userImageView, user: user)

        // style views
        styleViews()
        
        // Set total points available
        UserSkillPoints.getUserTotalPoints(user: user, success: {
            (userSkillPoint: PFObject?) -> () in
            let points = (userSkillPoint!["availablePoints"]! as! Int)
            self.userSkillPoint = userSkillPoint
            self.availablePointsLabel.text = "\(points)"
            if self.user.objectId! == BravoUser.getLoggedInUser().objectId! {
                self.redeemButton.isEnabled = points > 0
            }
            self.skills = "\((userSkillPoint!["skills"]! as! Array).joined(separator: ", "))"
            self.skillsLabel.text = self.skills

            
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
                self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
                self.isRefresh = true
            }, failure: {
                (error: Error?) -> () in
                self.givenPointsLabel.text = "\(givenPoints)"
                self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
                self.isRefresh = true
            })
        }, failure: {
            (error: Error?) -> () in
            self.givenPointsLabel.text = "\(givenPoints)"
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true
        })
        
    }
    
    func styleViews() {
        for viewToStyle in [availablePointView!, redeemedPointView!, givenPointView!, skillsLabel] {
            
            viewToStyle.layer.cornerRadius = 5.0
            viewToStyle.layer.masksToBounds = true
            viewToStyle.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            viewToStyle.layer.shadowOffset = CGSize(width: 0, height: 0)
            viewToStyle.layer.shadowOpacity = 0.8
            viewToStyle.alpha = 0.0
            UIView.animate(withDuration: 1.0, delay: 1.0,
                           options: .curveEaseInOut,
                           animations: {
                            viewToStyle.alpha = 1.0
            },
                           completion: nil)
            
            
        }
        
        if self.user.objectId! == BravoUser.getLoggedInUser().objectId! {

        //redeemButton.layer.cornerRadius = 5.0
        redeemButton.layer.masksToBounds = false
        redeemButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        redeemButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        redeemButton.layer.shadowOpacity = 0.8
        //redeemButton.layer.shadowRadius = 10.0
        }


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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: scrollView.frame.size.width)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.redeemButton.alpha = 0.0
        UIView.animate(withDuration: 1.0, delay: 1.0,
                                   options: .curveEaseInOut,
                                   animations: {
                                    self.redeemButton.alpha = 1.0
        },
        completion: nil)
        let redeemVC = segue.destination as! RedeemViewController
        redeemVC.availableRewardPoints = Int(self.availablePointsLabel.text!)
        redeemVC.userSkillPoint = userSkillPoint
        redeemVC.delegate = self
    }
}
