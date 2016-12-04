//
//  TimelineViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/24/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PostComposeViewControllerDelegate, PostCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    var postIdLikeMap = [Int : Bool]()
    
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

        // Initialize table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")

        getPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPosts()
    }

    func getPosts(){
        Post.getAllPosts(success: { (posts : [PFObject]?) in
            print("--- got \(posts?.count) posts")
            self.posts = posts!
            
            BravoUser.getUserPostLikes(success: {
                (postLikes: [PFObject]?) in
                for i in 0..<self.posts.count {
                    for postLike in postLikes! {
                        if self.posts[i].objectId! == (postLike["post"] as! PFObject).objectId! {
                            print ("post id matched")
                            self.postIdLikeMap[i] = true
                            break
                        }
                    }
                }
            }, failure: {
                (error: Error?) in
                print ("failed to get user post likes")
            })
            self.tableView.reloadData()
        }, failure: { (error : Error?) in
            print("---!!! cant get posts : \(error?.localizedDescription)")
        })
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        postCell.delegate = self
        postCell.likeButton.isSelected = postIdLikeMap[indexPath.row] ?? false
        postCell.post = posts[indexPath.row]
        
        return postCell
    }
    
    func comment(post: PFObject) {
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let postComposeNavControler = storyboard.instantiateViewController(withIdentifier: "PostComposeNavigationController") as! UINavigationController
        let postComposeVC = postComposeNavControler.topViewController as! PostComposeViewController
        postComposeVC.post = post
        postComposeVC.isComment = true
        postComposeVC.user = post["recipient"] as? PFUser

        
        present(postComposeNavControler, animated: true, completion: nil)

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Activity", bundle: nil)
        let commentsViewController = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        commentsViewController.post = posts[indexPath.row]
        show(commentsViewController, sender: self)
    }

    func postCompose(post: PFObject) {
        self.posts.insert(post, at: 0)
        tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let postComposeVC = navigationController.topViewController as! PostComposeViewController
        postComposeVC.isComment = false
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
