//
//  SignUpPhotoViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class SignUpPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var signUpUser: SignUpUser!
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
        guard signUpUser.password != nil else {
            print("---!!! MISSING PASSWORD")
            return
        }
        print("--- PASSWORD NOT NIL")
        
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let bu = BravoUser()
        bu.firstName = signUpUser.firstName
        bu.lastName = signUpUser.lastName
        bu.password = signUpUser.password
        bu.username = signUpUser.username
        bu.email = signUpUser.email
        
        bu.signUpUser {
            
            bu.logInUser {
                print("--- CREATE NEW ACCOUNT AND LOGIN success: \(bu.username)")
                
                let thisUser = PFUser.current()
                
                let defaults = UserDefaults.standard
                if let deviceTokenString = defaults.object(forKey: "deviceTokenString") as? String {
                    // if user permitted push notifications, save deviceTokenString to their profile
                    thisUser?["deviceTokenString"] = deviceTokenString
                    thisUser?.saveInBackground()
                }
                
                if let photo = self.signUpUser.photo {
                    let imageData = UIImagePNGRepresentation(photo)
                    let imageFile = PFFile(name:"image.png", data:imageData!)
                    
                    thisUser?["profileImage"] = imageFile
                    
                    thisUser?.saveInBackground(block: { (succeeded: Bool, error:Error?) in
                        if(succeeded == true){
                            print("--- new profile photo upload OK")
                        }else{
                            print("---!!! new profile photo upload FAIL")
                        }
                        
                        if let e = error{
                            print("---!!! new profile photo upload: \(e.localizedDescription)")
                        }
                    })
                
                }else{
                    print("---!!! new profile photo is nil?")
                }
                
                let storyBoard = UIStoryboard(name: "Activity", bundle: nil)
                
                let timelineNavigationController = storyBoard.instantiateViewController(withIdentifier: "TimelineNavigationController") as! UINavigationController
                let timelineViewController = timelineNavigationController.topViewController as! TimelineViewController
                timelineNavigationController.tabBarItem.title = "Timeline"
                //timelineNavigationController.tabBarItem.image = UIImage(named: "NoImage")
                
                
                let storyBoardTC = UIStoryboard(name: "TeamCreation", bundle: nil)
                let teamNavigationController = storyBoardTC.instantiateViewController(withIdentifier: "TeamNavigationController") as! UINavigationController
                //let teamViewController = teamNavigationController.topViewController as! TeamViewController
                teamNavigationController.tabBarItem.title = "Teams"
                //teamNavigationController.tabBarItem.image = UIImage(named: "NoImage")
                
                let leaderboardNavigationController = storyBoard.instantiateViewController(withIdentifier: "LeaderboardNavigationController") as! UINavigationController
                let leaderboardViewController = leaderboardNavigationController.topViewController as! LeaderboardViewController
                leaderboardNavigationController.tabBarItem.title = "Leaderboard"
                //leaderboardNavigationController.tabBarItem.image = UIImage(named: "NoImage")
                
                let profileNavigationController = storyBoard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
                let profileViewController = profileNavigationController.topViewController as! ProfileViewController
                profileNavigationController.tabBarItem.title = "Profile"
                //profileNavigationController.tabBarItem.image = UIImage(named: "NoImage")
                
                let tabBarController = UITabBarController()
                tabBarController.viewControllers = [timelineNavigationController, teamNavigationController, leaderboardNavigationController, profileNavigationController]
                //tabBarController.selectedViewController = teamNavigationController
                
                self.present(tabBarController, animated: true, completion: nil)
                
                
            }
            
        }
    }
    
    @IBAction func onPhotosTap(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            signUpUser.photo = image
            print("--- OK EDITED IMAGE ")
        } else{
            print("---??? FAIL EDITED IMAGE ")
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                print("--- OK ORIGINAL IMAGE ")
                signUpUser.photo = image
            }else{
                print("---!!! FAIL ORIGINAL IMAGE ")
            }
        }
        
        // Do something with the images (based on your use case)
        if let userPhoto = signUpUser.photo {
            selectedPhoto.image = userPhoto
        }
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCameraTap(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.camera
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func miscInit(){
        UIApplication.shared.statusBarStyle = .lightContent
        
        //emailTextField.becomeFirstResponder()
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128gray888.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(SignUpPhotoViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
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
