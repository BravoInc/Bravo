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
    
    var teamPhoto: UIImage?
    var team: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        
        if teamPhoto != nil {

            let imageData = UIImagePNGRepresentation(teamPhoto!)
            let imageFile = PFFile(name:"image.png", data:imageData!)
            
            team["teamImage"] = imageFile
            
            team.saveInBackground(block: { (succeeded: Bool, error:Error?) in
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
        rewardsVC.currentTeam = team
        
        //navigationController?.pushViewController(rewardsVC, animated: true)
        //present(rewardsVC, animated: true)

        
        let navController = UINavigationController(rootViewController: rewardsVC)
        //self.presentViewController(navController, animated:true, completion: nil)
        
        present(navController, animated: true, completion: nil)
        
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
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
