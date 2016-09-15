//
//  waterwheelLoginViewController.swift
//
//

import UIKit

extension UIViewController {

}
open class waterwheelLoginViewController: UIViewController {

    open let usernameField : UITextField = {
        let usernameField = UITextField()
        usernameField.autocorrectionType = .no
        usernameField.attributedPlaceholder = NSAttributedString(string: "Email")
        usernameField.translatesAutoresizingMaskIntoConstraints = false;
        usernameField.backgroundColor = UIColor.lightGray
        usernameField.textAlignment = .center
        usernameField.placeholder = "Username"
        usernameField.isHidden = true
        return usernameField
    }()

     open let passwordField : UITextField = {
        let passwordField = UITextField()
        passwordField.isSecureTextEntry = true
        passwordField.autocorrectionType = .no
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password")
        passwordField.backgroundColor = UIColor.lightGray
        passwordField.textAlignment = .center
        passwordField.translatesAutoresizingMaskIntoConstraints = false;
        passwordField.placeholder = "password"
        passwordField.isHidden = true
        passwordField.returnKeyType = .go
        return passwordField
    }()


    lazy open var submitButton : waterwheelAuthButton = {
        let submitButton = waterwheelAuthButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false;
        submitButton.backgroundColor = UIColor.darkGray
        submitButton.didPressLogin = {
            self.loginAction()
        }
        submitButton.didPressLogout = { (success, error) in
            self.logoutAction(success, error: error)
        }
        return submitButton
    }()

    lazy open var cancelButton : UIButton = {
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false;
        cancelButton.backgroundColor = UIColor.gray
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelButton.setTitle("Cancel", for: UIControlState())
        return cancelButton
    }()

    /**
     Provide a closure for when a Login Request is completed.
     */
    open var loginRequestCompleted: (_ success: Bool, _ error: NSError?) -> () = { _ in }

    /**
     Provide a closure for when a Logout Request is completed.
     */
    open var logoutRequestCompleted: (_ success: Bool, _ error: NSError?) -> () = { _ in }

    /**
     Provide a cancel button closure.
     */
    open var cancelButtonHit: () -> () = { _ in }

    override open func viewDidLoad() {
        super.viewDidLoad()
        configure(isInit:true)
    }
    /**
     Overridden viewDidAppear where decide if were logged in or not.

     - parameter animated: Is the view animated
     */
    override open func viewDidAppear(_ animated: Bool) {
        self.configure(isInit:false)
    }

    /**
     Configure this viewcontrollers view based on auth state.
     */

    open func configure(isInit: Bool) {
        if isInit {
            self.view.backgroundColor = UIColor.white
            // Incase of logout or login, we attach to the notification Center for the purpose of seeing requests.
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(configure),
                name: NSNotification.Name(rawValue: waterwheelNotifications.waterwheelDidFinishRequest.rawValue),
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
        usernameField.constrainEqual(.leadingMargin, to: view)
        usernameField.constrainEqual(.trailingMargin, to: view)
        usernameField.constrainEqual(.top, to: view, .top, multiplier: 1.0, constant: 44)
        usernameField.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    }

    /**
     Lays out the password field.
     */
    public func layoutPasswordField() {
        passwordField.constrainEqual(.leadingMargin, to: view)
        passwordField.constrainEqual(.trailingMargin, to: view)
        passwordField.constrainEqual(.bottomMargin, to: usernameField, .bottomMargin, multiplier: 1.0, constant: 55)
        passwordField.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    }

    /**
     Lays out the Submit Button
     */
    public func layoutSubmitButton() {
        submitButton.constrainEqual(.leadingMargin, to: view)
        submitButton.constrainEqual(.trailingMargin, to: view)
        submitButton.constrainEqual(.bottomMargin, to: passwordField, .bottomMargin, multiplier: 1.0, constant: 55)
        submitButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    }

    /**
     Lays out the Anonymous Button
     */
    public func layoutCancelButton() {
        cancelButton.constrainEqual(.leadingMargin, to: view)
        cancelButton.constrainEqual(.trailingMargin, to: view)
        cancelButton.constrainEqual(.bottomMargin, to: submitButton, .bottomMargin, multiplier: 1.0, constant: 55)
        cancelButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    }

    /**
     Remove anonymous subviews.
     */
    public func hideAnonymousSubviews() {
        usernameField.isHidden = true
        passwordField.isHidden = true
        cancelButton.isHidden = true
    }

    /**
     Add Anonymous subviews.
     */
    public func showAnonymousSubviews() {
        self.layoutSubviews()
        usernameField.isHidden = false
        passwordField.isHidden = false
        cancelButton.isHidden = false
    }

    /**
     Public Login Action function for the login button that runs our closure.
     */
    public func loginAction() {
        waterwheel.login(username: usernameField.text!, password: passwordField.text!) { (success, response, json, error) in
            if (success) {
                self.hideAnonymousSubviews()
            } else {
                print("failed to login")
            }
            self.loginRequestCompleted(success, error)
        }
    }

    /**
     Public Logout action that runs our closure.

     - parameter success: success or failure
     - parameter error:   if error happened.
     */
    open func logoutAction(_ success: Bool, error: NSError?) {
        if (success) {
            self.showAnonymousSubviews()
        } else {
            print("failed to logout")
        }
        self.logoutRequestCompleted(success, error)
    }


    open func cancelAction() {
        self.cancelButtonHit()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}
