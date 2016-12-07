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

class PostComposeViewController: UIViewController, UITextViewDelegate{
    var team: PFObject?
    var user: PFUser?
    var post: PFObject?
    var isComment: Bool!
    let placeholder = "What do you want to say?"
    

    let borderColor = UIColor(red: (136/255.0), green: (136/255.0), blue: (136/255.0), alpha: 1.0)
    let twitterBlack = UIColor(red: (20/255.0), green: (23/255.0), blue: (26/255.0), alpha: 1.0)

    @IBOutlet weak var scrollView: UIScrollView!
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
            //recipientTextField.backgroundColor = UIColor.lightGray
            recipientTextField.textColor = twitterBlack
            
            skillsTextField.text = "\(post!["skill"]!)"
            skillsTextField.isEnabled = false
            //skillsTextField.backgroundColor = UIColor.lightGray
            skillsTextField.textColor = twitterBlack
        }
        scrollView.keyboardDismissMode = .onDrag
        recipientTextField.inputView = UIView() // So that keyboard doesnt pop up
        setupTextView()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
    
    func setupTextView(){
        messageTextView.delegate = self
        messageTextView.autocapitalizationType = UITextAutocapitalizationType.sentences
        messageTextView.layer.borderColor = borderColor.cgColor
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.cornerRadius = 3.0
        setPlaceholder()
    }
    
    func setPlaceholder(){
        let startPosition : UITextPosition = messageTextView.beginningOfDocument
        messageTextView.text = placeholder
        messageTextView.textColor =  placeholderText
        messageTextView.selectedTextRange = messageTextView.textRange(from: startPosition, to: startPosition)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText =  textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            //isPlaceHolderShown = true
            textView.text = placeholder
            textView.textColor = placeholderText
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            //setButtonDisabled()
            //characterCountLabel.text = "\(characterLimit)"
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to dar gray to prepare for
            // the user's entry
        else if textView.textColor == placeholderText && !text.isEmpty {
            //isPlaceHolderShown = false
            textView.text = nil
            textView.textColor = twitterBlack
            //setButtonEnabled()
        }
        return true
        
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
            
            if let pushMessage = self.messageTextView.text {
                sendPushNotification(recipient: self.user!, message: "You got recognized! \(pushMessage)")
            }else{
                sendPushNotification(recipient: self.user!, message: "You got recognized! ")
            }

            
        }, failure: { (error : Error?) in
            print("---!!! cant create post : \(error?.localizedDescription)")
        })
        
        return newPost

    }

    func saveNewComment() -> PFObject {
        
        var points = 0
        
        if (pointsTextField.text != nil && pointsTextField.text != ""){
            points = Int(pointsTextField.text!)!
        }
        
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
        view.endEditing(true)
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
