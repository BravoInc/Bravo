//
//  MyCustomPageViewController.swift
//  TB_Walkthrough
//
//  Created by Yari D'areglia on 12/03/16.
//  Copyright © 2016 Bitwaker. All rights reserved.
//

import UIKit

class MyCustomPageViewController: BWWalkthroughPageViewController {
    
    //@IBOutlet var backgroundView: UIImageView!
    
    @IBOutlet weak var beginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.zPosition = -1000
        view.layer.isDoubleSided = false
        
        // disable for time being until bugfix
        beginButton.isEnabled = false
        beginButton.isHidden = true
    }
    
    @IBAction func onBeginButtonTap(_ sender: Any) {
        /*
        // some weird issue with this
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
        present(vc, animated: true, completion: nil)
 */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.backgroundView.layer.masksToBounds = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func walkthroughDidScroll(position: CGFloat, offset: CGFloat) {
        var tr = CATransform3DIdentity
        tr.m34 = -1/1000.0
        view.layer.transform = CATransform3DRotate(tr, CGFloat(M_PI)  * (1.0 - offset), 0.5,1, 0.2)
    }
    

}
