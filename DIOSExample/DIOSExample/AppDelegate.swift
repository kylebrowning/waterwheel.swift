//
//  AppDelegate.swift
//  DIOSExample
//
//  Created by Kyle Browning on 2/23/16.
//  Copyright © 2016 Kyle Browning. All rights reserved.
//

import UIKit
import DIOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //Basic Auth
        //DIOS.sharedInstance.setUserNameAndPassword("admin", password: "admin")
        
        //Cookie Auth
        let cookieUrl = NSURL(string: DIOS.sharedInstance.URL!)
        
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(cookieUrl!)
        
        if (cookies?.count >= 1) {
            //were logged in
            self.performLoggedInRequest()
        } else {
            //were not logged in
            self.loginWithCookieAuth({ (success, response, error) -> Void in
                if(success) {
                    self.performLoggedInRequest()
                }
            })
        }
        return true
    }
    func loginWithCookieAuth(completionHandler:(success:Bool, response:NSDictionary!, error:NSError!) -> Void) {
        DIOS.sharedInstance.logUserIn("admin", password: "admin") { (success, response, error) -> Void in
            completionHandler(success: success, response: response, error: error)
        }
    }
    func performLoggedInRequest () {
        DIOS.sharedInstance.sendRequest("node/1", method: .GET, params: nil) { (success, response, error) -> Void in
            if (success) {
                print (response)
            } else {
                print (error)
            }
        }
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

