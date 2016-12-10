//
//  LoginViewController.swift
//  Bravo
//
//  Created by Jay Liew on 12/2/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

import FBSDKCoreKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    let user = BravoUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miscInit()
        
        //let fbLoginButton = FBSDKLoginButton.init()
        
        //fbLoginButton.center = self.view.center
        // Optional: Place the button in the center of your view.
        
    }
    
    //Cannot convert value of type '[String]?.Type' (aka 'Optional<Array<String>>.Type') to expected argument type '[String]?'
    
    @IBAction func onFBTap(_ sender: Any) {
        
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email", "user_friends"],
                                          block: {
                                            (user: PFUser?, error: Error?) -> Void in
                                            if let user = user
                                            {
                                                if user.isNew {
                                                    print("User signed up and logged in through Facebook!")
                                                } else {
                                                    print("User logged in through Facebook!")
                                                }
                                                
                                                if let installation = PFInstallation.current() {
                                                    installation["user"] = PFUser.current()
                                                    installation.saveEventually()
                                                }
                                                
                                                
                                                
                                                let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name, last_name, id, email, picture.type(large)"])
                                                
                                                graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                                                    
                                                    print("--- GRAPH REQUEST START")
                                                    
                                                    if ((error) != nil){
                                                        print("Error: \(error?.localizedDescription)")
                                                    }
                                                    else {
                                                        // success
                                                        
                                                        print("--- GRAPH REQUEST SUCCESS")
                                                        
                                                        var userData: [String: AnyObject] = result as! [String : AnyObject]
                                                        
                                                        let picture: [String: AnyObject] = userData["picture"] as! [String: AnyObject]
                                                        
                                                        let imageData: [String: AnyObject] = picture["data"] as! [String : AnyObject]
                                                        
                                                        
                                                        if let x = userData["first_name"] as? String {
                                                            user["firstName"] = x
                                                        }
                                                        
                                                        if let x = userData["last_name"] as? String {
                                                            user["lastName"] = x
                                                        }
                                                        
                                                        if let x = userData["email"] as? String {
                                                            user["email"] = x
                                                        }
                                                        
                                                        print("--- \(user["firstName"]) ||| \(user["lastName"]) +++ \(user["email"])")
                                                        
                                                        if let x = imageData["url"] as? String {
                                                            user["fbProfilePhotoUrl"] = x
                                                            print("--- FB IMAGE DATA: \(x)")
                                                            
                                                            let url = URL(string: x)!
                                                            DispatchQueue.global().async {
                                                                let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                                                                DispatchQueue.main.async {
                                                                    let photoFromUrl = UIImage(data: data!)
                                                                    
                                                                    if let photo = photoFromUrl {
                                                                        let imageData = UIImagePNGRepresentation(photo)
                                                                        let imageFile = PFFile(name:"image.png", data:imageData!)
                                                                        
                                                                        user["profileImage"] = imageFile
                                                                        
                                                                        user.saveInBackground(block: { (succeeded: Bool, error:Error?) in
                                                                            if(succeeded == true){
                                                                                print("--- new profile photo upload OK")
                                                                            }else{
                                                                                print("---!!! new profile photo upload FAIL")
                                                                            }
                                                                            
                                                                            if let e = error{
                                                                                print("---!!! new profile photo upload: \(e.localizedDescription)")
                                                                            }
                                                                        }) // save in bg
                                                                        
                                                                    } // if photo
                                                                    
                                                                }
                                                            } // global dispatch
                                                            
                                                        }
                                                        
                                                        //print("--- IMAGE DATA URL FROM FB: \(imageData["url"])")
                                                        
                                                        user.saveInBackground(block: { (result: Bool, error: Error?) in
                                                            if result {
                                                                print("--- Successfully FB log ina and saved data")
                                                            }
                                                            if error != nil {
                                                                print("Error: \(error?.localizedDescription)")
                                                            }
                                                            
                                                        })
                                                    }
                                                }) // graphRequest
                                                
                                                self.present(afterSuccessLogin(), animated: true, completion: nil)
                                                
                                            } else {
                                                print("Uh oh. The user cancelled the Facebook login.")
                                            } // else
        } //block
        )
        

    } // fb button tap
    
    @IBAction func onLogin(_ sender: Any) {
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        user.logInUser(success: {
                self.present(afterSuccessLogin(), animated: true, completion: nil)
        })
    }
    
    func miscInit(){
        UIApplication.shared.statusBarStyle = .lightContent
        usernameTextField.becomeFirstResponder()
        // transparentNavBar()
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let backImage = UIImage(named: "backArrow128white.png")!
        button.setImage(backImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(NameViewController.backButtonPressed), for: UIControlEvents.touchUpInside)
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
