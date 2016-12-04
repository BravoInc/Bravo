//
//  PostCell.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse
import DateTools

@objc protocol PostCellDelegate {
    @objc optional func comment(post: PFObject)
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var recipientImageView: UIImageView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    var isLikedByCurrentUser: Bool = false
    weak var delegate: PostCellDelegate?
    
    var post: PFObject! {
        didSet {
            let sender = post["sender"] as! BravoUser
            let recipient = post["recipient"] as! BravoUser
            
            recipientNameLabel.text = "\(recipient["firstName"]!) \(recipient["lastName"]!)"
            senderLabel.text = "\(sender["firstName"]!)"
            messageLabel.text = "+\(post["points"]!) for \(post["message"]!) \(post["skill"]!)"
            
            // Setting sender and recipient image views
            setImageView(imageView: senderImageView, user: sender)
            setImageView(imageView: recipientImageView, user: recipient)
            
            pointsLabel.textColor = greenColor
            pointsLabel.text = "+" + ("\(post["points"]!)")
            
            if (post.createdAt != nil ){
                let timeSinceNow = NSDate(timeIntervalSinceNow: post.createdAt!.timeIntervalSinceNow)
                timeLabel.text = timeSinceNow.shortTimeAgoSinceNow()
            }
            
            if likeButton.isSelected {
                likeButton.setImage(UIImage(named: "heart_red"), for: UIControlState.selected)

            } else {
                likeButton.setImage(UIImage(named: "heart"), for: UIControlState.normal)

            }
            
            self.updateUI()
        }
    }
    
    func updateUI(){
        backgroundCardView.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        //contentView.backgroundColor = greenColor
        backgroundCardView.layer.cornerRadius = 5.0
        backgroundCardView.layer.masksToBounds = false
        
        backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        backgroundCardView.layer.shadowOpacity = 0.8
        
        
    }
        
    private func updateLikeCount() {
        likeButton.isSelected = !likeButton.isSelected
        if likeButton.isSelected {
            likeButton.setImage(UIImage(named: "heart_red"), for: UIControlState.selected)
        } else {
            //tweet.retweetCount -= 1
            likeButton.setImage(UIImage(named: "heart"), for: UIControlState.normal)
        }
        //retweetCountLabel.text = "\(tweet.retweetCount)"
    }
        
        
    @IBAction func onCommentTapped(_ sender: Any) {
        delegate?.comment?(post: post)
    }
    
    @IBAction func onLikeTapped(_ sender: Any) {
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
