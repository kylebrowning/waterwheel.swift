//
//  waterwheelLoginViewController.swift
//  Pods
//
//  Created by Kyle Browning on 8/1/16.
//
//

import UIKit

public class waterwheelLoginViewController: UIViewController {

    let loginField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton(type: .System)
    let stackView   = UIStackView()
    var originalLayoutConstraint : NSArray = []
    var other : NSArray = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.addSubviews()
        self.layoutViews()

        // Do any additional setup after loading the view.
    }
    public func layoutViews() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        loginField.autocorrectionType = .No
        loginField.attributedPlaceholder = NSAttributedString(string: "Email")
        loginField.heightAnchor.constraintEqualToConstant(50.0).active = true
        loginField.widthAnchor.constraintEqualToConstant(screenWidth).active = true

        originalLayoutConstraint = loginField.constraints

        loginField.backgroundColor = UIColor.lightGrayColor()
        loginField.textAlignment = .Center

        passwordField.secureTextEntry = true
        passwordField.autocorrectionType = .No
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password")
        passwordField.heightAnchor.constraintEqualToConstant(50.0).active = true
        passwordField.widthAnchor.constraintEqualToConstant(screenWidth).active = true
        passwordField.backgroundColor = UIColor.lightGrayColor()
        passwordField.textAlignment = .Center

        loginButton.setTitle("Login", forState: .Normal)
        loginButton.heightAnchor.constraintEqualToConstant(50.0).active = true
        loginButton.widthAnchor.constraintEqualToConstant(screenWidth).active = true
        loginButton.backgroundColor = UIColor.darkGrayColor()
        loginButton.addTarget(self, action: "loginAction", forControlEvents: UIControlEvents.TouchUpInside)


        //Stack View

        stackView.axis  = UILayoutConstraintAxis.Vertical
        stackView.distribution  = UIStackViewDistribution.EqualSpacing
        stackView.alignment = UIStackViewAlignment.Center
        stackView.spacing   = 5.0

        //Constraints
        stackView.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
    }

    public func loginAction() {
        waterwheel.sharedInstance.loginWithUserLoginForm(loginField.text!, password: passwordField.text!) { (success, response, json, error) in
            print(response)
        }
    }

    public func addSubviews() {
        stackView.addArrangedSubview(loginField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(stackView)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
