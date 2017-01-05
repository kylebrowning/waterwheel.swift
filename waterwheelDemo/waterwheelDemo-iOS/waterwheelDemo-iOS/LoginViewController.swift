//
//  ViewController.swift
//  waterwheelDemo
//
//  Created by Kyle Browning on 8/16/16.
//  Copyright © 2016 Acquia. All rights reserved.
//

import UIKit
import waterwheel
// NO such module error? run `carthage update`

class LoginViewController: UIViewController {

    @IBOutlet weak var authButton: waterwheelAuthButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Lets build our default waterwheelLoginViewController.
        let vc = waterwheelLoginViewController()

        // Lets add some default username and passwords so that we can demo login/logout
        vc.usernameField.text = "waterwheelDemo"
        vc.passwordField.text = "waterwheelDemo!"

        // Lets add our function that will be run when the request is completed.
        vc.loginRequestCompleted = { (success, error) in
            if (success) {
                // Do something related to a successfull login
                print("successfull login")
                self.dismiss(animated: true, completion: nil)
            } else {
                print (error!)
            }
        }

        // Define our logout action
        vc.logoutRequestCompleted = { (success, error) in
            if (success) {
                print("successfull logout")
                // Do something related to a successfull logout
                self.dismiss(animated: true, completion: nil)
            } else {
                print (error!)
            }
        }

        // Define our cancel button action
        vc.cancelButtonHit = {
            self.dismiss(animated: true, completion: nil)
        }

        // Do any additional setup after loading the view, typically from a nib.
        authButton.didPressLogin = {
            // Lets Present our Login View Controller since this closure is for the loginButton press
            self.present(vc, animated: true, completion: nil)
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

