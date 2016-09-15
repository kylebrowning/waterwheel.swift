//
//  waterwheelAuthButton.swift
//  Only For use in iOS


import UIKit
import Alamofire
import SwiftyJSON

/**
 Provide an enum to handle.

 - Login:  login Auth Action
 - Logout: logout Auth Action
 */
public enum AuthAction: String {
    case Login = "Login", Logout = "Logout"
}


/// A UIButton subclass that will always display the logged in state.
open class waterwheelAuthButton: UIButton {

    open var didPressLogin: () -> () = { _ in }
    open var didPressLogout: (_ success:Bool, _ error: NSError?) -> () = { success, error in }

    /**
      A initializer to handle run once code for the button.
     */
    fileprivate func initButton() -> () {
        // Incase of logout or login, we attach to the notification Center for the purpose of seeing requests.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureButton),
            name: NSNotification.Name(rawValue: waterwheelNotifications.waterwheelDidFinishRequest.rawValue),
            object: nil)

        self.translatesAutoresizingMaskIntoConstraints = false;
        self.setTitleColor(UIButton(type: UIButtonType.system).titleColor(for: UIControlState())!, for: UIControlState())
        self.configureButton()
    }
    /**
     Override init to setup our button.

     - parameter frame: frame for view

     - returns:
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initButton()
    }

    /**
     Configures the button for its current state.
     */
    open func configureButton() {

        if waterwheel.isLoggedIn() {
            self.setTitle("Logout", for: UIControlState())
            self.removeTarget(self, action: #selector(waterwheelAuthButton.loginAction), for: .touchUpInside)
            self.addTarget(self, action: #selector(waterwheelAuthButton.logoutAction), for: .touchUpInside)
        } else {
            self.setTitle("Login", for: UIControlState())
            self.removeTarget(self, action: #selector(waterwheelAuthButton.logoutAction), for: .touchUpInside)
            self.addTarget(self, action: #selector(waterwheelAuthButton.loginAction), for: .touchUpInside)
        }
    }

    /// This is required for Swift
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initButton()
    }


    /**
     This method provies an action to take when the button is in a logged in state.
     We automatically log the user out, but provide a closure that can be used to do anything else base on the outcome.

     */

    open func logoutAction() {
        waterwheel.logout { (success, response, json, error) in
            self.didPressLogout(success, error)
        }
    }

    /**
     This method provies an action to take when the button is in a logged out state.

     */
    open func loginAction() {
        self.didPressLogin()
    }
}


