//
//  CommentsViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/26/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var recipientImageView: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!

    var comments = [PFObject]()
    var post: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation bar title view
        let titleLabel = UILabel()
        titleLabel.text =
        "Comments"
        titleLabel.sizeToFit()
        titleLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        navigationItem.titleView = titleLabel

        // Initialize table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
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
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        commentCell.comment = comments[indexPath.row]

        return commentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func postCompose(post: PFObject) {
        self.comments.append(post)
        tableView.reloadData()
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
