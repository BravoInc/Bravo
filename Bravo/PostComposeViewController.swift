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
    var post: PFObject?
    var isComment: Bool!
    
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var pointsTextField: UITextField!
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    weak var delegate: PostComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isComment == true {
            let recipient = post!["recipient"] as! BravoUser
            recipientTextField.text = "\(recipient["firstName"]!) \(recipient["lastName"]!)"
            recipientTextField.isEnabled = false
            recipientTextField.backgroundColor = UIColor.lightGray
            
            skillsTextField.text = "\(post!["skill"]!)"
            skillsTextField.isEnabled = false
            skillsTextField.backgroundColor = UIColor.lightGray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func saveNewPost() -> PFObject {
        let points = Int(pointsTextField.text!)!
        let newPost = Post.createPost(recipient: user!, message: messageTextView.text!, skill: skillsTextField.text!, points: points, team: team!)
        let skills = skillsTextField.text!.components(separatedBy: "#")
        
        Post.savePost(post: newPost, success: { (post : PFObject?) in
            print("-- new post \(post)")
            for skillStr in skills {
                let skillName = skillStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if skillName.characters.count == 0 {
                    continue
                }
                UserSkillPoints.saveUserSkillPoints(user: self.user!, skillName: skillName, points: points, success: {(userSkillPoint: PFObject?) in
                    Skills.saveSkill(skillName: skillName, user: self.user!, points: points, success: { (skill: PFObject?) in
                        print ("--new skill \(skill)")
                    }, failure: { (error: Error?) in
                        print ("Error saving skill: \(error?.localizedDescription)")
                    })
                }, failure: {(error: Error?) in
                    print ("--Error adding points. Skip adding skills")
                    
                })
            }
            
            sendPushNotification(recipient: self.user!, message: "You got recognized! \(self.messageTextView.text)")
            
        }, failure: { (error : Error?) in
            print("---!!! cant create post : \(error?.localizedDescription)")
        })
        
        return newPost

    }

    func saveNewComment() -> PFObject {
        let points = Int(pointsTextField.text!)!
        let newComment = Comment.createComment(post: post!, message: messageTextView.text!, points: points)
        let skills = skillsTextField.text!.components(separatedBy: "#")
        print ("spliting by hashtags \(skills)")
        
        Comment.saveComment(comment: newComment, post: post!, success: { (comment : PFObject?) in
            print("-- new comment \(comment)")
            for skillStr in skills {
                let skillName = skillStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                print ("skill to create a comment for: \(skillName)")
                if skillName.characters.count == 0 {
                    continue
                }
                
                UserSkillPoints.saveUserSkillPoints(user: self.user!, skillName: skillName, points: points, success: {(userSkillPoint: PFObject?) in
                    Skills.saveSkill(skillName: skillName, user: self.user!, points: points, success: { (skill: PFObject?) in
                        print ("-- updated existing skill with user points\(skill)")
                    }, failure: { (error: Error?) in
                        print ("Error updating skill with user points: \(error?.localizedDescription)")
                    })
                }, failure: {(error: Error?) in
                    print ("--Error adding points. Skip adding skills")
                    
                })
            }
        }, failure: { (error : Error?) in
            print("---!!! cant create comment : \(error?.localizedDescription)")
        })
        
        return newComment
    }
    
    @IBAction func createPost(_ sender: Any) {
        let newPost = isComment == true ? saveNewComment() : saveNewPost()
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
