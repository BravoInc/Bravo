//
//  SignUpPhotoViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TeamPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectedPhoto: UIImageView!
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var camOrGalAfterTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var camOrGalAfterLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var camOrGalBeforeTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var camOrGalBeforeLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectedPhotoAspectRatioConstraint: NSLayoutConstraint!
    
    var teamPhoto: UIImage?
    var team: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
        nextButton.isHidden = true
        selectedPhoto.isHidden = true
        //selectedPhotoAspectRatioConstraint?.isActive = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if teamPhoto != nil {
            // after selection of first photo
            print("--- viewwillappear: team photo exists")
            /*
            camOrGalAfterTrailingConstraint?.isActive = true
            camOrGalAfterLeadingConstraint?.isActive = true
            
            camOrGalBeforeTrailingConstraint?.isActive = false
            camOrGalBeforeLeadingConstraint?.isActive = false
            */
            nextButton.isHidden = false
            selectedPhoto.isHidden = false
            //selectedPhotoAspectRatioConstraint?.isActive = true
            
        }else{
            // before selection of first photo
            print("--- viewwillappear: no team photo")
            /*
            camOrGalAfterTrailingConstraint?.isActive = false
            camOrGalAfterLeadingConstraint?.isActive = false
            
            camOrGalBeforeTrailingConstraint?.isActive = true
            camOrGalBeforeLeadingConstraint?.isActive = true
            */
            nextButton.isHidden = true
            selectedPhoto.isHidden = true
            //selectedPhotoAspectRatioConstraint?.isActive = false
        }
    }

    
    @IBAction func onSignUp(_ sender: Any) {
        
        Team.isNewTeam(teamName: teamNameTextField.text!, success: {
            Team.createTeam(teamName: self.teamNameTextField.text!, success: { (team : PFObject) in
                print("--- team created : \(self.teamNameTextField.text!)")
                self.team = team
                
                
                if self.teamPhoto != nil {
                    
                    let imageData = UIImagePNGRepresentation(self.teamPhoto!)
                    let imageFile = PFFile(name:"image.png", data:imageData!)
                    
                    self.team["teamImage"] = imageFile
                    
                    self.team.saveInBackground(block: { (succeeded: Bool, error:Error?) in
                        if(succeeded == true){
                            print("--- new team photo upload OK")
                        }else{
                            print("---!!! new team photo upload FAIL")
                        }
                        
                        if let e = error{
                            print("---!!! new team photo upload: \(e.localizedDescription)")
                        }
                    })
                    
                } // photo not nil
                
                let storyboard = UIStoryboard(name: "TeamCreation", bundle: nil)
                let rewardsVC = storyboard.instantiateViewController(withIdentifier: "RewardsViewController") as! RewardsViewController
                rewardsVC.currentTeam = self.team
                
                self.show(rewardsVC, sender: self)

                
                
            })
        }, failure: {
            //self.showTeamErrorDialog(teamName: self.teamNameTextField.text!)
            self.teamNameTextField.text = ""
        })
        
    } //on next button
    
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
            teamPhoto = image
            print("--- OK EDITED IMAGE ")
        } else{
            print("---??? FAIL EDITED IMAGE ")
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                print("--- OK ORIGINAL IMAGE ")
                teamPhoto = image
            }else{
                print("---!!! FAIL ORIGINAL IMAGE ")
            }
        }
        
        // Do something with the images (based on your use case)
        if teamPhoto != nil {
            selectedPhotoAspectRatioConstraint?.isActive = true
            selectedPhoto.image = teamPhoto
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
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: nil, action: nil)

    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
