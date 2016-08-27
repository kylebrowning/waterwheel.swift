//
//  waterwheelLoginViewController.swift
//
//

import UIKit
import waterwheel

extension UIViewController {

}
public class waterwheelLoginViewController: UIViewController {

    public let usernameField : UITextField = {
        let usernameField = UITextField()
        usernameField.autocorrectionType = .No
        usernameField.attributedPlaceholder = NSAttributedString(string: "Email")
        usernameField.translatesAutoresizingMaskIntoConstraints = false;
        usernameField.backgroundColor = UIColor.lightGrayColor()
        usernameField.textAlignment = .Center
        usernameField.placeholder = "Username"
        usernameField.hidden = true
        return usernameField
    }()

     public let passwordField : UITextField = {
        let passwordField = UITextField()
        passwordField.secureTextEntry = true
        passwordField.autocorrectionType = .No
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password")
        passwordField.backgroundColor = UIColor.lightGrayColor()
        passwordField.textAlignment = .Center
        passwordField.translatesAutoresizingMaskIntoConstraints = false;
        passwordField.placeholder = "password"
        passwordField.hidden = true
        passwordField.returnKeyType = .Go
        return passwordField
    }()


    lazy public var submitButton : waterwheelAuthButton = {
        let submitButton = waterwheelAuthButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.darkGrayColor()
        submitButton.didPressLogin = {
            self.loginAction()
        }
        submitButton.didPressLogout = { (success, error) in
            self.logoutAction(success, error: error)
        }
        return submitButton
    }()

    lazy public var cancelButton : UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false;
        cancelButton.backgroundColor = UIColor.grayColor()
        cancelButton.addTarget(self, action: #selector(cancelAction), forControlEvents: .TouchUpInside)
        cancelButton.setTitle("Cancel", forState: .Normal)
        return cancelButton
    }()

    /**
     Provide a closure for when a Login Request is completed.
     */
    public var loginRequestCompleted: (success: Bool, error: NSError?) -> () = { _ in }

    /**
     Provide a closure for when a Logout Request is completed.
     */
    public var logoutRequestCompleted: (success: Bool, error: NSError?) -> () = { _ in }

    /**
     Provide a cancel button closure.
     */
    public var cancelButtonHit: () -> () = { _ in }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configure(isInit:true)
    }
    /**
     Overridden viewDidAppear where decide if were logged in or not.

     - parameter animated: Is the view animated
     */
    override public func viewDidAppear(animated: Bool) {
        self.configure(isInit:false)
    }

    /**
     Configure this viewcontrollers view based on auth state.
     */

    public func configure(isInit isInit: Bool) {
        if isInit {
            self.view.backgroundColor = .whiteColor()
            // Incase of logout or login, we attach to the notification Center for the purpose of seeing requests.
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(configure),
                name: waterwheelNotifications.waterwheelDidFinishRequest.rawValue,
                object: nil)

            self.view.addSubview(usernameField)
            self.view.addSubview(passwordField)
            self.view.addSubview(submitButton)
            self.view.addSubview(cancelButton)
        }
        if !waterwheel.isLoggedIn() {
            self.showAnonymousSubviews()
        } else {
            // We do nothing because our waterwheelAuthButton will handle its own state
        }
    }

    /**
     Layout the Anonymous Subviews.
     */
    public func layoutSubviews() {
        self.layoutLoginField()
        self.layoutPasswordField()
        self.layoutSubmitButton()
        self.layoutCancelButton()
    }

    /**
     Lays out the login field.
     */
    public func layoutLoginField() {
        usernameField.constrainEqual(.LeadingMargin, to: view)
        usernameField.constrainEqual(.TrailingMargin, to: view)
        usernameField.constrainEqual(.Top, to: view, .Top, multiplier: 1.0, constant: 44)
        usernameField.heightAnchor.constraintEqualToConstant(50.0).active = true
    }

    /**
     Lays out the password field.
     */
    public func layoutPasswordField() {
        passwordField.constrainEqual(.LeadingMargin, to: view)
        passwordField.constrainEqual(.TrailingMargin, to: view)
        passwordField.constrainEqual(.BottomMargin, to: usernameField, .BottomMargin, multiplier: 1.0, constant: 55)
        passwordField.heightAnchor.constraintEqualToConstant(50.0).active = true
    }

    /**
     Lays out the Submit Button
     */
    public func layoutSubmitButton() {
        submitButton.constrainEqual(.LeadingMargin, to: view)
        submitButton.constrainEqual(.TrailingMargin, to: view)
        submitButton.constrainEqual(.BottomMargin, to: passwordField, .BottomMargin, multiplier: 1.0, constant: 55)
        submitButton.heightAnchor.constraintEqualToConstant(50.0).active = true
    }

    /**
     Lays out the Anonymous Button
     */
    public func layoutCancelButton() {
        cancelButton.constrainEqual(.LeadingMargin, to: view)
        cancelButton.constrainEqual(.TrailingMargin, to: view)
        cancelButton.constrainEqual(.BottomMargin, to: submitButton, .BottomMargin, multiplier: 1.0, constant: 55)
        cancelButton.heightAnchor.constraintEqualToConstant(50.0).active = true
    }

    /**
     Remove anonymous subviews.
     */
    public func hideAnonymousSubviews() {
        usernameField.hidden = true
        passwordField.hidden = true
        cancelButton.hidden = true
    }

    /**
     Add Anonymous subviews.
     */
    public func showAnonymousSubviews() {
        self.layoutSubviews()
        usernameField.hidden = false
        passwordField.hidden = false
        cancelButton.hidden = false
    }

    /**
     Public Login Action function for the login button that runs our closure.
     */
    public func loginAction() {
        waterwheel.login(usernameField.text!, password: passwordField.text!) { (success, response, json, error) in
            if (success) {
                self.hideAnonymousSubviews()
            } else {
                print("failed to login")
            }
            self.loginRequestCompleted(success: success, error: error)
        }
    }

    /**
     Public Logout action that runs our closure.

     - parameter success: success or failure
     - parameter error:   if error happened.
     */
    public func logoutAction(success: Bool, error: NSError?) {
        if (success) {
            self.showAnonymousSubviews()
        } else {
            print("failed to logout")
        }
        self.logoutRequestCompleted(success: success, error: error)
    }


    public func cancelAction() {
        self.cancelButtonHit()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}