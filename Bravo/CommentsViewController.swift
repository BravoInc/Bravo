//
//  CommentsViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/26/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

@objc protocol CommentsViewControllerDelegate {
    @objc optional func postLiked(post: PFObject, isLiked: Bool)
}

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostComposeViewControllerDelegate, AddCommentCellDelegate {
    
    
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var recipientImageView: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var comments = [PFObject]()
    var post: PFObject!
    var isPostLiked: Bool!
    var team: PFObject!
    weak var delegate: CommentsViewControllerDelegate?
    var isSenderAnimating = false
    
    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sender = post["sender"] as! BravoUser
        let recipient = post["recipient"] as! BravoUser
        
        // Setting image views
        setImageView(imageView: senderImageView, user: sender)
        setImageView(imageView: recipientImageView, user: recipient)
        
        setupForAnimation()
        
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
        
        //recipientNameLabel.text = "\(recipient["firstName"]!) \(recipient["lastName"]!)"
        postHeaderTextCreate(recipient: recipient, sender: sender, team : team,headerLabel: recipientNameLabel)
        messageLabel.text = "\(post["message"]!) \(post["skill"]!)"
        
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
        
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getComments), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)
        
        getComments(refreshControl: progressControl.refreshControl)
        
    }
    
    func startSpin(){
        if(!isSenderAnimating){
            isSenderAnimating = true
            spinWithOptions(options: UIViewAnimationOptions.curveEaseIn)
        }
    }
    
    func stopSpin(){
        isSenderAnimating = false
    }
    
    func spinWithOptions(options : UIViewAnimationOptions){
        UIView.animate(withDuration: 0.5, delay: 0, options: options, animations: {
            if(self.senderImageView != nil ){
                self.senderImageView.transform = CGAffineTransform(rotationAngle: CGFloat(235))
            } else {
                print("---!!! imageview nil")
            }
        }, completion: { (finished : Bool) in
            if (finished){
                if (self.isSenderAnimating){
                    print("--- still animating")
                    self.spinWithOptions(options: UIViewAnimationOptions.curveLinear)
                }
                else if options != UIViewAnimationOptions.curveEaseOut {
                    self.spinWithOptions(options: UIViewAnimationOptions.curveEaseOut)
                }
            }
        })
    }
    
    func setupForAnimation(){
        // Make images tiny
        let rotate = CGAffineTransform(rotationAngle: CGFloat(-360))
        let scaleAndRotate = rotate.scaledBy(x: 0.1, y: 0.1)
        
        self.senderImageView.transform = scaleAndRotate
        self.recipientImageView.transform = scaleAndRotate
        
        self.pointsLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.arrowImageView.alpha = 0
    }
    
    func animateStuff(){
        let rotate = CGAffineTransform(rotationAngle: CGFloat(M_PI)*8)
        let scaleAndRotate = rotate.scaledBy(x: 1, y: 1)
        
        UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.senderImageView.transform = scaleAndRotate
        }) { (completion : Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                self.arrowImageView.alpha = 1
            }, completion: { (finished : Bool) in
                if (finished){
                    
                    UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        self.recipientImageView.transform = scaleAndRotate
                    }, completion: { (finished : Bool) in
                        if (finished){
                            UIView.animate(withDuration: 0.5, animations: {
                                self.arrowImageView.alpha = 0
                            })
                            self.animatePoints()
                        }
                    })
                }
            })
        }
    }
    
    func animatePoints(){
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.pointsLabel.transform = .identity
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getComments(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }
        Comment.getComments(post: post, success: { (comments : [PFObject]?) in
            print("--- got \(comments?.count) comments")
            self.comments = comments!
            self.tableView.reloadData()
            self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
            self.animateStuff()
            self.isRefresh = true
        }, failure: { (error : Error?) in
            print("---!!! cant get comments : \(error?.localizedDescription)")
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            self.isRefresh = true
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
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
        delegate?.postLiked?(post: post, isLiked: self.likeButton.isSelected)
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
