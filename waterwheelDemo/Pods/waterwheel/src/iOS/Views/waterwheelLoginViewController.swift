//
//  waterwheelLoginViewController.swift
//
//

import UIKit
import waterwheel

extension UIViewController {

}
public class waterwheelLoginViewController: UIViewController {

    let usernameField = UITextField()
    let passwordField = UITextField()
    let submitButton = waterwheelAuthButton()

    /// Provide a closure for when a Login Request is completed.
    public var loginRequestCompleted: (success: Bool, error: NSError?) -> () = { _ in }
    /// Provide a closure for when a Logout Request is completed.
    public var logoutRequestCompleted: (success: Bool, error: NSError?) -> () = { _ in }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .whiteColor()
        if !waterwheel.isLoggedIn() {
            self.setupAnonymousView()
        } else {
            self.setupAuthenticatedView()
        }
        // Incase of logout or login, we attach to the notification Center for the purpose of seeing requests.
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(configure),
            name: waterwheelNotifications.waterwheelDidFinishRequest.rawValue,
            object: nil)
    }
    /**
     Overridden viewDidAppear where decide if were logged in or not.

     - parameter animated: Is the view animated
     */
    override public func viewDidAppear(animated: Bool) {
        self.configure()
    }

    /**
     Configure this viewcontrollers view based on auth state.
     */

    public func configure() {
        if !waterwheel.isLoggedIn() {
            self.setupAnonymousView()
        } else {
            self.setupAuthenticatedView()
        }
    }

    /**
     Setup the authenticated Subviews.
     */
    public func setupAuthenticatedView() {
        self.configureAuthenticatedSubviews()
        self.addAuthenticatedSubviews()
        self.layoutAuthenticatedSubviews()

    }
    /**
     Setup the Anonymous Subviews.
     */
    public func setupAnonymousView() {
        self.configureAnonymousSubviews()
        self.addAnonymousSubviews()
        self.layoutAnonymousSubviews()
    }

    /**
     Configure authenticated Subviews.
     */
    public func configureAuthenticatedSubviews() {
        self.configureAuthenticatedButton()
    }

    /**
     Configure Anonymous Subviews.
     */
    public func configureAnonymousSubviews() {
        self.configureUsernameField()
        self.configurePasswordField()
        self.configureAnonymousButton()
    }

    /**
     Configure the username field defaults.
     */
    public func configureUsernameField() {
        usernameField.autocorrectionType = .No
        usernameField.attributedPlaceholder = NSAttributedString(string: "Email")
        usernameField.translatesAutoresizingMaskIntoConstraints = false;
        usernameField.backgroundColor = UIColor.lightGrayColor()
        usernameField.textAlignment = .Center
        usernameField.placeholder = "Username"
    }
    /**
     Configure the password field defaults.
     */
    public func configurePasswordField() {
        passwordField.secureTextEntry = true
        passwordField.autocorrectionType = .No
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password")
        passwordField.backgroundColor = UIColor.lightGrayColor()
        passwordField.textAlignment = .Center
        passwordField.translatesAutoresizingMaskIntoConstraints = false;
        passwordField.placeholder = "test"
    }

    /**
     Configure Anonymous button defaults.
     */
    public func configureAnonymousButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.darkGrayColor()
        submitButton.didPressLogin = {
            self.loginAction()
        }
    }

    /**
     Configure Authenticated Button defaults.
     */
    public func configureAuthenticatedButton() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.darkGrayColor()
        submitButton.didPressLogout = { (success, error) in
            self.logoutAction(success, error: error)
        }
    }

    /**
     Layout the Anonymous Subviews.
     */
    public func layoutAnonymousSubviews() {
        self.layoutLoginField()
        self.layoutPasswordField()
        self.layoutAnonymousButton()
    }

    /**
     Layout the Authenticated Subviews.
     */
    public func layoutAuthenticatedSubviews() {
        self.layoutAuthenticatedButton()
    }

    /**
     Lays out the authenticated button.
     */
    public func layoutAuthenticatedButton() {
        submitButton.constrainEqual(.LeadingMargin, to: view)
        submitButton.constrainEqual(.TrailingMargin, to: view)
        submitButton.constrainEqual(.Bottom, to: view, .Bottom, multiplier: 1.0, constant: -100)
        submitButton.heightAnchor.constraintEqualToConstant(50.0).active = true
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
     Lays out the Anonymous Button
     */
    public func layoutAnonymousButton() {
        submitButton.constrainEqual(.LeadingMargin, to: view)
        submitButton.constrainEqual(.TrailingMargin, to: view)
        submitButton.constrainEqual(.BottomMargin, to: passwordField, .BottomMargin, multiplier: 1.0, constant: 55)
        submitButton.heightAnchor.constraintEqualToConstant(50.0).active = true
    }

    /**
     Removes authenticated Subviews
     */
    public func removeAuthenticatedSubviews() {
        submitButton.removeFromSuperview()
        submitButton.removeTarget(self, action: #selector(waterwheelLoginViewController.logoutAction), forControlEvents: .TouchUpInside)
    }

    /**
     Adds authenticated Subviews.
     */
    public func addAuthenticatedSubviews() {
        self.view.addSubview(submitButton)
    }

    /**
     Remove anonymous subviews.
     */
    public func removeAnonymousSubviews() {
        usernameField.removeFromSuperview()
        passwordField.removeFromSuperview()
        submitButton.removeFromSuperview()
        submitButton.removeTarget(self, action: #selector(waterwheelLoginViewController.loginAction), forControlEvents: .TouchUpInside)
    }

    /**
     Add Anonymous subviews.
     */
    public func addAnonymousSubviews() {
        self.view.addSubview(usernameField)
        self.view.addSubview(passwordField)
        self.view.addSubview(submitButton)
    }

    /**
     Public Login Action function for the login button that runs our closure.
     */
    public func loginAction() {
        waterwheel.login(usernameField.text!, password: passwordField.text!) { (success, response, json, error) in
            if (success) {
                self.removeAnonymousSubviews()
                self.setupAuthenticatedView()
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
            self.removeAuthenticatedSubviews()
            self.setupAnonymousView()
        } else {
            print("failed to logout")
        }
        self.logoutRequestCompleted(success: success, error: error)
    }


    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}