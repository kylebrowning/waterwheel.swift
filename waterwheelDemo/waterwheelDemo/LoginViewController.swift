//
//  ViewController.swift
//  waterwheelDemo
//
//  Created by Kyle Browning on 8/16/16.
//  Copyright © 2016 Acquia. All rights reserved.
//

import UIKit
import waterwheel

class LoginViewController: UIViewController {

    @IBOutlet weak var authButton: waterwheelAuthButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        authButton.didPressLogin = {
            // Lets build our default waterwheelLoginViewController.
            let vc = waterwheelLoginViewController()
            //Lets add our function that will be run when the request is completed.
            vc.loginRequestCompleted = { (success, error) in
                if (success) {
                    // Do something related to a successfull login
                    print("successfull login")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print (error)
                }
            }
            vc.logoutRequestCompleted = { (success, error) in
                if (success) {
                    print("successfull logout")
                    // Do something related to a successfull logout
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print (error)
                }
            }
            // Lets Present our Login View Controller since this closure is for the loginButton press
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        authButton.didPressLogout = { (success, error) in
            print("logged out")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

