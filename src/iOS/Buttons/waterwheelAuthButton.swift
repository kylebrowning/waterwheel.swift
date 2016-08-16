//
//  waterwheelAuthButton.swift
//  Only For use in iOS


import UIKit
import waterwheel
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
public class waterwheelAuthButton: UIButton {

    public var didPressLogin: () -> () = { _ in }
    public var didPressLogout: (success:Bool, error: NSError?) -> () = { success, error in }

    /**
      A initializer to handle run once code for the button.
     */
    private func initButton() -> () {
        // Incase of logout or login, we attach to the notification Center for the purpose of seeing requests.
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(configureButton),
            name: waterwheelNotifications.waterwheelDidFinishRequest.rawValue,
            object: nil)

        self.translatesAutoresizingMaskIntoConstraints = false;
        self.setTitleColor(UIButton(type: UIButtonType.System).titleColorForState(.Normal)!, forState: .Normal)
        self.configureButton()
    }
    /**
     Override init to setup our button.

     - parameter frame: frame for view

     - returns:
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initButton()
    }

    override public func awakeFromNib() {
        self.initButton()
    }
    /**
     Configures the button for its current state.
     */
    public func configureButton() {

        if waterwheel.isLoggedIn() {
            self.setTitle("Logout", forState: .Normal)
            self.removeTarget(self, action: #selector(waterwheelAuthButton.loginAction), forControlEvents: .TouchUpInside)
            self.addTarget(self, action: #selector(waterwheelAuthButton.logoutAction), forControlEvents: .TouchUpInside)
        } else {
            self.setTitle("Login", forState: .Normal)
            self.removeTarget(self, action: #selector(waterwheelAuthButton.logoutAction), forControlEvents: .TouchUpInside)
            self.addTarget(self, action: #selector(waterwheelAuthButton.loginAction), forControlEvents: .TouchUpInside)
        }
    }

    /// This is required for Swift
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     This method provies an action to take when the button is in a logged in state.
     We automatically log the user out, but provide a closure that can be used to do anything else base on the outcome.

     */

    public func logoutAction() {
        waterwheel.logout { (success, response, json, error) in
            self.didPressLogout(success: success, error: error)
        }
    }

    /**
     This method provies an action to take when the button is in a logged out state.

     */
    public func loginAction() {
        self.didPressLogin()
    }
}


