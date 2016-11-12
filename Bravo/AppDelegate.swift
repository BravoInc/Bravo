//
//  AppDelegate.swift
//  Bravo
//
//  Created by Patwardhan, Saurabh on 11/7/16.
//  Copyright © 2016 BravoInc. All rights reserved.
//

import UIKit
import Parse


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let appID = "CTLT83tmRhI9WG8ryn5faymg4eanXhsDiNhm18dj"
    let clientKey = "OWOvOsMyzRnfa5E9Swv2adzYiMbwj9vYQlSEY46I"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // Initialize Parse.
        Parse.setApplicationId(appID, clientKey: clientKey)
        
        // Test Parse User signIn
        // TODO : Remove this ASAP
        let newUser = PFUser()
        // set user properties
        newUser.username = "testuser"
        newUser.email = "test@gmail.com"
        newUser.password = "pword"
        
        // call sign up function on the object
        newUser.signUpInBackground { (result : Bool, error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }else {
                print("User Registered successfully")
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

