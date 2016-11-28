//
//  PostComposeViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/26/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse


@objc protocol PostComposeViewControllerDelegate {
    @objc optional func postCompose(post: PFObject)
}

class PostComposeViewController: UIViewController {
    var team: PFObject?
    var user: PFUser?
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var pointsTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    weak var delegate: PostComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func createPost(_ sender: Any) {
        if user == nil {
            return
        }
        let newPost = Post.createPost(recipient: user!, message: messageTextView.text, points: Int(pointsTextField.text!)!, team: team!)
        
        
        Post.savePost(post: newPost, success: { (post : PFObject?) in
            print("-- new post \(post)")
            
        }, failure: { (error : Error?) in
            print("---!!! cant create post : \(error?.localizedDescription)")
        })
        delegate?.postCompose?(post: newPost)
        dismiss(animated: true, completion: nil)
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
        
        selectionNavController.setViewControllers([selectionVC], animated: true)
        self.present(selectionNavController, animated: true, completion: nil)

    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        print ("unwind")
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
