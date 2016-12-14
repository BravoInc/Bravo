//
//  TimelineViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostComposeViewControllerDelegate, PostCellDelegate, CommentsViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    var postIdLikeMap = [String : Bool]()
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    // Progress control
    let progressControl = ProgressControls()
    var isRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation bar title view and back button
        /*let titleLabel = UILabel()
        titleLabel.text =
        "Reward Activity"
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        */
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Activity", style: .plain, target: nil, action: nil)
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        let rightImage = UIImage(named: "plusCompose")!
        button.setImage(rightImage, for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(onCompose), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem?.customView = button

        
        // Initialize table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        // When activated, invoke our refresh function
        progressControl.setupRefreshControl()
        progressControl.refreshControl.addTarget(self, action: #selector(getPosts), for: UIControlEvents.valueChanged)
        tableView.insertSubview(progressControl.refreshControl, at: 0)

        getPosts(refreshControl: progressControl.refreshControl)
    }
    
    func getPosts(refreshControl: UIRefreshControl){
        // Show Progress HUD before fetching posts
        if !isRefresh {
            progressControl.showProgressHud(owner: self, view: self.view)
        }
        Post.getAllPosts(success: { (posts : [PFObject]?) in
            print("--- got \(posts?.count) posts")
            self.posts = posts!
            
            BravoUser.getUserPostLikes(success: {
                (postLikes: [PFObject]?) in
                for i in 0..<self.posts.count {
                    for postLike in postLikes! {
                        if self.posts[i].objectId! == (postLike["post"] as! PFObject).objectId! {
                            print ("post id matched")
                            print ("\(posts?[i]["message"]) - \(posts?[i]["likeCount"]) \((postLike["post"] as! PFObject)["isLiked"])")
                            self.postIdLikeMap[self.posts[i].objectId!] = (postLike["isLiked"]! as! Bool)
                            break
                        }
                    }
                }
                self.tableView.reloadData()
                
                self.progressControl.hideControls(delayInSeconds: 1.0, isRefresh: self.isRefresh, view: self.view)
                self.isRefresh = true

            }, failure: {
                (error: Error?) in
                print ("failed to get user post likes")
                self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
                self.isRefresh = true

            })

        }, failure: { (error : Error?) in
            self.progressControl.hideControls(delayInSeconds: 0.0, isRefresh: self.isRefresh, view: self.view)
            print("---!!! cant get posts : \(error?.localizedDescription)")
            self.isRefresh = true
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressControl.checkScrollView(tableViewSize: self.tableView.frame.size.width)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        postCell.delegate = self
        let postId = posts[indexPath.row].objectId ?? ""
        postCell.isLiked = postIdLikeMap[postId] ?? false
        let currPost = posts[indexPath.row]
        print ("\(currPost["team"] as? PFObject) \(currPost["message"])")
        let team = currPost["team"] as! PFObject
        
        postCell.team = team
        postCell.commentButton.tag = indexPath.row
        postCell.post = posts[indexPath.row]
        
        return postCell
    }
    
    func comment(post: PFObject, postIndex: Int) {
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let postComposeNavControler = storyboard.instantiateViewController(withIdentifier: "PostComposeNavigationController") as! UINavigationController
        let postComposeVC = postComposeNavControler.topViewController as! PostComposeViewController
        postComposeVC.post = post
        postComposeVC.isComment = true
        postComposeVC.postIndex = postIndex
        postComposeVC.user = post["recipient"] as? PFUser
        postComposeVC.delegate = self

        
        present(postComposeNavControler, animated: true, completion: nil)

    }
    
    func like(post: PFObject, isLiked: Bool) {
        postIdLikeMap[post.objectId!] = isLiked
    }

    func postLiked(post: PFObject, isLiked: Bool, postIndex: Int) {
        postIdLikeMap[post.objectId!] = isLiked
        let indexPath = IndexPath(row: postIndex, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func postCommentedOn(post: PFObject, postIndex: Int) {
        let indexPath = IndexPath(row: postIndex, section: 0)

        let postCell = tableView.cellForRow(at: indexPath) as! PostCell
        postCell.commentCountLabel.text = "\(Int(postCell.commentCountLabel.text!)!+1)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let commentsViewController = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        
        let currPost = posts[indexPath.row]
        let team = currPost["team"] as! PFObject
        
        commentsViewController.post = posts[indexPath.row]
        commentsViewController.isPostLiked = postIdLikeMap[posts[indexPath.row].objectId!] ?? false
        commentsViewController.team = team
        commentsViewController.delegate = self
        commentsViewController.postIndex = indexPath.row
        
        show(commentsViewController, sender: self)
    }

    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        CellAnimator.animateCell(cell: cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.5)
    }*/
    
    func postCompose(post: PFObject, isComment: Bool, postIndex: Int) {
        if isComment {
            let indexPath = IndexPath(row: postIndex, section: 0)
            
            let postCell = tableView.cellForRow(at: indexPath) as! PostCell
            postCell.commentCountLabel.text = "\(Int(postCell.commentCountLabel.text!)!+1)"
        } else {
            self.posts.insert(post, at: 0)
            tableView.reloadData()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onCompose() {
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let postComposeNavControler = storyboard.instantiateViewController(withIdentifier: "PostComposeNavigationController") as! UINavigationController
        let postComposeVC = postComposeNavControler.topViewController as! PostComposeViewController
        postComposeVC.isComment = false
        postComposeVC.postIndex = 0
        postComposeVC.delegate = self
        present(postComposeNavControler, animated: true, completion: nil)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let postComposeVC = navigationController.topViewController as! PostComposeViewController
        postComposeVC.isComment = false
        postComposeVC.postIndex = 0
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
