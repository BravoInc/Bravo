//
//  CommentsViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/26/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostComposeViewControllerDelegate, AddCommentCellDelegate {
    
    
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var recipientImageView: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    var comments = [PFObject]()
    var post: PFObject!
    var isPostLiked: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation bar title view
        let titleLabel = UILabel()
        titleLabel.text =
        "Comments"
        titleLabel.sizeToFit()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 18)
        navigationItem.titleView = titleLabel
        
        
        // Initialize table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        tableView.register(UINib(nibName: "AddCommentCell", bundle: nil), forCellReuseIdentifier: "AddCommentCell")
        
        let sender = post["sender"] as! BravoUser
        let recipient = post["recipient"] as! BravoUser
        
        //recipientNameLabel.text = "\(recipient["firstName"]!) \(recipient["lastName"]!)"
        postHeaderTextCreate(recipient: recipient, sender: sender, headerLabel: recipientNameLabel)
        messageLabel.text = "+\(post["points"]!) for \(post["message"]!) #\(post["skill"]!)"
        
        // Setting image views
        setImageView(imageView: senderImageView, user: sender)
        setImageView(imageView: recipientImageView, user: recipient)
        
        pointsLabel.textColor = greenColor
        pointsLabel.text = "+" + ("\(post["points"]!)")
        
        tableView.tableFooterView = UIView()
        
        likeCountLabel.text = "\(post["likeCount"]!)"
        likeButton.isSelected = isPostLiked
        if likeButton.isSelected {
            likeButton.setImage(UIImage(named: "thumbsup_filled"), for: UIControlState.selected)
            
        } else {
            likeButton.setImage(UIImage(named: "thumbsup_outline"), for: UIControlState.normal)
            
        }
        commentCountLabel.text = "\(post["commentCount"]!)"
        
        getComments(post: post)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getComments(post: PFObject){
        Comment.getComments(post: post, success: { (comments : [PFObject]?) in
            print("--- got \(comments?.count) comments")
            self.comments = comments!
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get comments : \(error?.localizedDescription)")
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1 // For Add Comment Cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row < comments.count ){
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            commentCell.comment = comments[indexPath.row]
            return commentCell
        } else {
            let addCommentCell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell", for: indexPath) as! AddCommentCell
            addCommentCell.delegate = self
            return addCommentCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func postCompose(post: PFObject) {
        self.comments.append(post)
        tableView.reloadData()
    }
    
    func comment() {
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let postComposeNavControler = storyboard.instantiateViewController(withIdentifier: "PostComposeNavigationController") as! UINavigationController
        let postComposeVC = postComposeNavControler.topViewController as! PostComposeViewController
        postComposeVC.post = post
        postComposeVC.isComment = true
        postComposeVC.user = post["recipient"] as? PFUser
        postComposeVC.delegate = self
        
        present(postComposeNavControler, animated: true, completion: nil)
    }
    
    private func updateLikeCount() {
        likeButton.isSelected = !likeButton.isSelected
        if likeButton.isSelected {
            likeButton.setImage(UIImage(named: "thumbsup_filled"), for: UIControlState.selected)
        } else {
            likeButton.setImage(UIImage(named: "thumbsup_outline"), for: UIControlState.normal)
        }
        let incrementBy = likeButton.isSelected ? 1 : -1
        likeCountLabel.text = "\(Int(likeCountLabel.text!)!+incrementBy)"
    }

    @IBAction func onLikeButton(_ sender: Any) {
        self.updateLikeCount()
        Post.updateLikeCount(post: post, increment: likeButton.isSelected, success: {
            (post: PFObject?) -> () in
            BravoUser.saveUserPostLikes(post: post!, isLiked: self.likeButton.isSelected, success: { (postLike: PFObject?) in
                print ("--successfully updated user post like")
            }, failure: { (error: Error?) in
                print ("-- failed to update user post like: \(error?.localizedDescription)")
            })
        }, failure: { (error: Error?) in
            print ("-- failed to update post like count: \(error?.localizedDescription)")
            self.updateLikeCount()
        }
        )

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let postComposeVC = navigationController.topViewController as! PostComposeViewController
        postComposeVC.isComment = true
        postComposeVC.post = post
        postComposeVC.user = post!["recipient"] as? PFUser
        postComposeVC.delegate = self
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
