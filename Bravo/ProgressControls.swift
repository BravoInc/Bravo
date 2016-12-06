//
//  ProgressControls.swift
//  Bravo
//
//  Created by Unum Sarfraz on 12/5/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class ProgressControls {
    var refreshLoadingView : UIView!
    var refreshColorView : UIView!
    var compass_background : UIImageView!
    var compass_spinner : UIImageView!
    
    // Refresh Control stuff
    var isRefreshIconsOverlap = false
    var isRefreshAnimating = false
    var refreshControl: UIRefreshControl!
    
    // MBProgressHUD stuff
    var hud: MBProgressHUD!
    var labelsArray = [UILabel]()
    var isLoadAnimating = false
    
    var currentColorIndex = 0
    var currentLabelIndex = 0

    func loadCustomView(owner: Any?) -> UIView {
        let loadContents = Bundle.main.loadNibNamed("RefreshContents", owner: owner, options: nil)
        let customView = loadContents![0] as! UIView
        customView.backgroundColor = UIColor.clear
        
        // Load labels array
        for i in 0..<customView.subviews.count {
            labelsArray.append(customView.viewWithTag(i + 1) as! UILabel)
        }
        
        return customView
    }
    
    func animateLoadStep1(hud: MBProgressHUD) {
        isLoadAnimating = true
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            self.labelsArray[self.currentLabelIndex].textColor = self.getNextColor()
            
        }, completion: { (finished) -> Void in
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.labelsArray[self.currentLabelIndex % self.labelsArray.count].transform = CGAffineTransform.identity
                self.labelsArray[self.currentLabelIndex % self.labelsArray.count].textColor = UIColor.black
                
            }, completion: { (finished) -> Void in
                self.currentLabelIndex += 1
                
                if self.currentLabelIndex < self.labelsArray.count {
                    self.animateLoadStep1(hud: hud)
                }
                else {
                    self.animateLoadStep2(hud: hud)
                }
            })
        })
    }
    
    func animateLoadStep2(hud: MBProgressHUD) {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.labelsArray[0].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[1].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[2].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[3].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[4].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.labelsArray[0].transform = CGAffineTransform.identity
                self.labelsArray[1].transform = CGAffineTransform.identity
                self.labelsArray[2].transform = CGAffineTransform.identity
                self.labelsArray[3].transform = CGAffineTransform.identity
                self.labelsArray[4].transform = CGAffineTransform.identity
                
            }, completion: { (finished) -> Void in
                if hud.alpha == 0 {
                    // Hide operation
                    self.isLoadAnimating = false
                    self.currentLabelIndex = 0
                    for i in 0..<self.labelsArray.count {
                        self.labelsArray[i].textColor = UIColor.black
                        self.labelsArray[i].transform = CGAffineTransform.identity
                    }
                }
                else {
                    self.currentLabelIndex = 0
                    self.animateLoadStep1(hud: hud)
                }
            })
        })
    }
    
    func getNextColor() -> UIColor {
        var colorsArray = [purpleColor, greenColor, orangeColor, UIColor.magenta, UIColor.yellow]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }

    func showProgressHud(owner: Any?, view: UIView) {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView
        hud.customView = loadCustomView(owner: owner)
        hud.minSize = CGSize(width: (hud.customView?.frame.size.width)! * 2, height: (hud.customView?.frame.size.height)!)
        animateLoadStep1(hud: hud)
    }
    
    func hideControls(delayInSeconds: TimeInterval, isRefresh: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            if !isRefresh {
               self.hud.hide(animated: true)
            }
            
            self.refreshControl!.endRefreshing()
        }
    }
    
    func setupRefreshControl() {
        
        // Programmatically inserting a UIRefreshControl
        self.refreshControl = UIRefreshControl()
        
        // Setup the loading view, which will hold the moving graphics
        self.refreshLoadingView = UIView(frame: self.refreshControl!.bounds)
        self.refreshLoadingView.backgroundColor = UIColor.clear
        
        // Setup the color view, which will display the rainbowed background
        self.refreshColorView = UIView(frame: self.refreshControl!.bounds)
        self.refreshColorView.backgroundColor = UIColor.clear
        self.refreshColorView.alpha = 0.30
        
        // Create the graphic image views
        compass_background = UIImageView(image: UIImage(named: "compass_background"))
        self.compass_spinner = UIImageView(image: UIImage(named: "compass_spinner"))
        
        // Add the graphics to the loading view
        self.refreshLoadingView.addSubview(self.compass_background)
        self.refreshLoadingView.addSubview(self.compass_spinner)
        
        // Clip so the graphics don't stick out
        self.refreshLoadingView.clipsToBounds = true
        
        // Hide the original spinner icon
        self.refreshControl!.tintColor = UIColor.clear
        
        // Add the loading and colors views to our refresh control
        self.refreshControl!.addSubview(self.refreshColorView)
        self.refreshControl!.addSubview(self.refreshLoadingView)
        
        // Initalize flags
        self.isRefreshIconsOverlap = false
        self.isRefreshAnimating = false
        
    }
    
    func checkScrollView(tableViewSize: CGFloat) {
        // Get the current size of the refresh controller
        var refreshBounds = self.refreshControl!.bounds;
        
        // Distance the table has been pulled >= 0
        let pullDistance = max(0.0, -self.refreshControl!.frame.origin.y);
        
        // Half the width of the table
        let midX = tableViewSize / 2.0;
        
        // Calculate the width and height of our graphics
        let compassHeight = self.compass_background.bounds.size.height;
        let compassHeightHalf = compassHeight / 2.0;
        
        let compassWidth = self.compass_background.bounds.size.width;
        let compassWidthHalf = compassWidth / 2.0
        
        let spinnerHeight = self.compass_spinner.bounds.size.height;
        let spinnerHeightHalf = spinnerHeight / 2.0
        
        let spinnerWidth = self.compass_spinner.bounds.size.width;
        let spinnerWidthHalf = spinnerWidth / 2.0
        
        // Calculate the pull ratio, between 0.0-1.0
        let pullRatio = min( max(pullDistance, 0.0), 100.0) / 100.0;
        
        // Set the Y coord of the graphics, based on pull distance
        let compassY = pullDistance / 2.0 - compassHeightHalf
        let spinnerY = pullDistance / 2.0 - spinnerHeightHalf
        
        // Calculate the X coord of the graphics, adjust based on pull ratio
        var compassX = (midX + compassWidthHalf) - (compassWidth * pullRatio);
        var spinnerX = (midX - spinnerWidth - spinnerWidthHalf) + (spinnerWidth * pullRatio);
        
        // When the compass and spinner overlap, keep them together
        if (fabsf(Float(compassX - spinnerX)) < 1.0) {
            self.isRefreshIconsOverlap = true
        }
        
        // If the graphics have overlapped or we are refreshing, keep them together
        if (self.isRefreshIconsOverlap || self.refreshControl!.isRefreshing) {
            compassX = midX - compassWidthHalf
            spinnerX = midX - spinnerWidthHalf
        }
        
        // Set the graphic's frames
        var compassFrame = self.compass_background.frame
        compassFrame.origin.x = compassX
        compassFrame.origin.y = compassY
        
        var spinnerFrame = self.compass_spinner.frame
        spinnerFrame.origin.x = spinnerX
        spinnerFrame.origin.y = spinnerY
        
        self.compass_background.frame = compassFrame
        self.compass_spinner.frame = spinnerFrame
        
        // Set the encompassing view's frames
        refreshBounds.size.height = pullDistance
        
        self.refreshColorView.frame = refreshBounds
        self.refreshLoadingView.frame = refreshBounds
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (self.refreshControl!.isRefreshing && !self.isRefreshAnimating) {
            self.animateRefreshView()
        }
        
    }
    
    
    func animateRefreshView() {
        
        
        // Background color to loop through for our color view
        
        var colorArray = [UIColor.red, UIColor.blue, UIColor.purple, UIColor.cyan, UIColor.orange, UIColor.magenta]
        
        // In Swift, static variables must be members of a struct or class
        struct ColorIndex {
            static var colorIndex = 0
        }
        
        // Flag that we are animating
        self.isRefreshAnimating = true
        
        UIView.animate(
            withDuration: Double(0.3),
            delay: Double(0.0),
            options: UIViewAnimationOptions.curveLinear,
            animations: {
                // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                self.compass_spinner.transform = self.compass_spinner.transform.rotated(by: CGFloat(M_PI_2))
                
                // Change the background color
                self.refreshColorView!.backgroundColor = colorArray[ColorIndex.colorIndex]
                ColorIndex.colorIndex = (ColorIndex.colorIndex + 1) % colorArray.count
        },
            completion: { finished in
                // If still refreshing, keep spinning, else reset
                if (self.refreshControl!.isRefreshing) {
                    self.animateRefreshView()
                }else {
                    self.resetAnimation()
                }
        }
        )
    }
    
    func resetAnimation() {
        
        // Reset our flags and }background color
        self.isRefreshAnimating = false
        self.isRefreshIconsOverlap = false
        self.refreshColorView.backgroundColor = UIColor.clear
    }
    

}
