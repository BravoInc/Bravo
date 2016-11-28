//
//  CommentsViewController.swift
//  Bravo
//
//  Created by Unum Sarfraz on 11/26/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse

class CommentsViewController: UIViewController {

    var comments = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getComments(post: PFObject){
        Comment.getComments(post: post, success: { (comments : [PFObject]?) in
            print("--- got \(comments?.count) comments")
            self.comments = comments!
        }, failure: { (error : Error?) in
            print("---!!! cant get comments : \(error?.localizedDescription)")
        })
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
