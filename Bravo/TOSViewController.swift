//
//  TOSViewController.swift
//  Bravo
//
//  Created by Jay Liew on 11/27/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit

class TOSViewController: UIViewController {

    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "http://www.newp.pl/bravo")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        
        automaticallyAdjustsScrollViewInsets = false
    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
