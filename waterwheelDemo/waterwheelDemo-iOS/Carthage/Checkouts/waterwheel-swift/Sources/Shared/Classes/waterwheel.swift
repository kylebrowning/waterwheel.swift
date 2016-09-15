//
//  waterwheel.swift
//
//  Created by Kyle Browning on 1/25/16.
//  Copyright © 2016 Kyle Browning. All rights reserved.
//

import SwiftyJSON
import SwiftyUserDefaults
import Alamofire

extension DefaultsKeys {
    static let basicUsername = DefaultsKey<String?>("basicUsername")
    static let basicPassword = DefaultsKey<String?>("basicPassword")
    static let logoutToken = DefaultsKey<String?>("logoutToken")
    static let csrfToken = DefaultsKey<String?>("csrfToken")
    static let signRequestsBasic = DefaultsKey<Bool?>("signRequestsBasic")
    static let signCSRFToken = DefaultsKey<Bool?>("signCSRFToken")
    static let isLoggedIn = DefaultsKey<Bool?>("isLoggedIn")
}


public enum EntityType: String {
    case Node = "node", Comment = "comment"
}


public enum waterwheelNotifications: String {
    case waterwheelDidLogin
    case waterwheelDidLogout
    case waterwheelDidStartRequest
    case waterwheelDidFinishRequest
}

public enum waterwheelNotificationsTypes: String {
    case checkLoginStatus
    case login
    case logout
    case getCSRF
    case normalRequest
}

// MARK: - Typelias definitions

public typealias completion = (_ success:Bool, _ response:DataResponse<Any>?, _ json:JSON?, _ error:NSError?) -> Void
public typealias stringcompletion = (_ success:Bool, _ response:DataResponse<String>?, _ json:JSON?, _ error:NSError?) -> Void
public typealias paramType = [String: AnyObject]?


private let waterwheelErrorString = "waterhwheel error: "

/**
 Responsible for storing state and variables for waterwheel.
 */
open class waterwheelManager {


    // MARK: - Properties

    /**
     A shared instance of `waterwheelManager`
     */
    open static let sharedInstance: waterwheelManager = {
        return waterwheelManager(basicUsername: "", basicPassword: "", logoutToken: "", CSRFToken: "", signRequestsBasic: false, signCSRFToken: false, isLoggedIn: false)
    }()

    open let requestFormat = "?_format=json"
    var headers = [
        "Content-Type":"application/json",
        "Accept":"application/json",
        ]
    open var URL : String = ""
    fileprivate var basicUsername : String = ""
    fileprivate var basicPassword : String = ""
    fileprivate var logoutToken : String = ""
    fileprivate var CSRFToken : String = ""
    fileprivate var signRequestsBasic : Bool = false
    fileprivate var signCSRFToken : Bool = false
    fileprivate var isLoggedIn: Bool = false

    /**
     Initializes the `waterwheel` instance with the our defaults.
     - returns: The new `waterwheel` instance.
     */
    public init(basicUsername: String, basicPassword: String, logoutToken: String, CSRFToken: String, signRequestsBasic: Bool, signCSRFToken: Bool, isLoggedIn: Bool) {

        if let basicUsername = Defaults[.basicUsername] {
            self.basicUsername = basicUsername
        } else {
            self.basicUsername = ""
        }
        if let basicPassword = Defaults[.basicPassword] {
            self.basicPassword = basicPassword
        } else {
            self.basicPassword = ""
        }

        if let logoutToken = Defaults[.logoutToken] {
            self.logoutToken = logoutToken
        } else {
            self.logoutToken = ""
        }

        if let CSRFToken = Defaults[.csrfToken] {
            self.CSRFToken = CSRFToken
        } else {
            self.CSRFToken = ""
        }

        if let signRequestsBasic = Defaults[.signRequestsBasic] {
            self.signRequestsBasic = signRequestsBasic
        } else {
            self.signRequestsBasic = false
        }

        if let signCSRFToken = Defaults[.signCSRFToken] {
            self.signCSRFToken = signCSRFToken
        } else {
            self.signRequestsBasic = false
        }

        if let isLoggedIn = Defaults[.isLoggedIn] {
            self.isLoggedIn = isLoggedIn
        } else {
            self.isLoggedIn = false
        }
    }
}

/**
 Sets the URL for all requests to be sent against.

 - parameter drupalURL:         The URL for the Drupal Site

 */
public func setDrupalURL(_ drupalURL: String) {
    assert(drupalURL != "", waterwheelErrorString + "Missing Drupal URL")
    waterwheelManager.sharedInstance.URL = drupalURL;
    waterwheel.checkLoginStatus()
}


/**
 Private function to check Login Status with all cookies that have been set.

 */
private func checkLoginStatus() {
    postNotification(waterwheelNotifications.waterwheelDidStartRequest.rawValue, requestName: waterwheelNotificationsTypes.checkLoginStatus.rawValue, object: nil)
    let urlString = waterwheelManager.sharedInstance.URL + "/user/login_status" + waterwheelManager.sharedInstance.requestFormat
    Alamofire.request(urlString)
        .validate(statusCode: 200..<300)
        .responseString{ response in
            if (response.result.error == nil) {
                let loginStatus = String(data: response.data!, encoding: String.Encoding.utf8)
                if (loginStatus == "1") {
                    setIsLoggedIn(true)
                } else {
                    setIsLoggedIn(false)
                }
            }
            else {
                setIsLoggedIn(false)
            }
            postNotification(waterwheelNotifications.waterwheelDidFinishRequest.rawValue, requestName: waterwheelNotificationsTypes.checkLoginStatus.rawValue, object: response.response)
    }
}


// MARK: - Authentication methods

/**
 Allows a username and password to be set for Basic Auth

 - parameter username:          The username to login with.
 - parameter password:          The password to login with

 */
public func setBasicAuthUsernameAndPassword(_ username:String, password:String, sign: Bool) {
    waterwheelManager.sharedInstance.basicUsername = username
    waterwheelManager.sharedInstance.basicPassword = password
    waterwheelManager.sharedInstance.signRequestsBasic = sign
    Defaults[.basicUsername] = username
    Defaults[.basicPassword] = password
    Defaults[.signRequestsBasic] = true
    setIsLoggedIn(true)
}


/**
 Login

 - parameter username:          The username to login with.
 - parameter password:          The password to login with
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.


 */
public func login(username:String?, password:String?, completionHandler: completion?) {

    assert(username! != "", waterwheelErrorString + "Missing username.")
    assert(password! != "", waterwheelErrorString + "Missing password.")

    let body = [
        "name":username!,
        "pass":password!
    ]

    postNotification(waterwheelNotifications.waterwheelDidStartRequest.rawValue, requestName: waterwheelNotificationsTypes.login.rawValue, object: nil)

    sendRequest("user/login", method: .post, params: body as paramType) { (success, response, json, error) in
        switch response!.result {
        case .success( _):
            let csrfToken = json!["csrf_token"].string
            let logoutToken = json!["logout_token"].string
            setCSRF(csrfToken!, sign: true)
            setLogoutToken(logoutToken!)
            waterwheel.setIsLoggedIn(true)
            completionHandler?(true, response, json, nil)
        case .failure(let error):
            completionHandler?(false, response, nil, error as NSError?)
        }
        postNotification(waterwheelNotifications.waterwheelDidFinishRequest.rawValue, requestName: waterwheelNotificationsTypes.login.rawValue, object: response?.response)
    }
}



/**
 Logout a user

 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func logout(completionHandler: completion?) {
    if waterwheelManager.sharedInstance.signRequestsBasic  {
        waterwheelManager.sharedInstance.basicUsername = ""
        waterwheelManager.sharedInstance.basicPassword = ""
        waterwheelManager.sharedInstance.signRequestsBasic = false
        return
    }
    postNotification(waterwheelNotifications.waterwheelDidFinishRequest.rawValue, requestName: waterwheelNotificationsTypes.login.rawValue, object: nil)

    let urlString = waterwheelManager.sharedInstance.URL + "/user/logout" + waterwheelManager.sharedInstance.requestFormat + "&token=" + waterwheelManager.sharedInstance.logoutToken
    sendRequestWithUrl(urlString, method: .post, params: nil) { (success, response, json, error) in
        if (response!.result.error == nil) {
            setCSRF("", sign: false)
            setIsLoggedIn(false)
            completionHandler?(true, response, nil, response!.result.error as NSError?)
        }
        else {
            completionHandler?(false, response, nil, response!.result.error as NSError?)
        }
        postNotification(waterwheelNotifications.waterwheelDidFinishRequest.rawValue, requestName: waterwheelNotificationsTypes.login.rawValue, object: response?.response)
    }
}

/**

 Private function to get the CSRF Token

 */
private func getCSRFToken(_ completionHandler: stringcompletion?) {
    let urlString = waterwheelManager.sharedInstance.URL + "/rest/session/token"
    Alamofire.request(urlString)
        .validate(statusCode: 200..<300)
        .responseString{ response in
            if (response.result.error == nil) {
                let csrfToken = String(data: response.data!, encoding: String.Encoding.utf8)
                setCSRF(csrfToken!, sign: true)
                completionHandler?(true, response, nil, nil)
            }
            else {
                completionHandler?(false, response, nil, response.result.error as NSError?)
            }
    }
}

// MARK: - Requests


/**
 Sends a request to Drupal with a specified path

 - parameter path:              The path for the request.
 - parameter method:            The method, eg, GET, POST etc.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func sendRequest(_ path:String, method:Alamofire.HTTPMethod, params:paramType, completionHandler: completion?) {
    assert(waterwheelManager.sharedInstance.URL != "", "waterwheel Error: Mission Drupal URL. Did you set it properly?")
    let urlString = waterwheelManager.sharedInstance.URL + "/" + path + waterwheelManager.sharedInstance.requestFormat
    sendRequestWithUrl(urlString, method: method, params: params, completionHandler: completionHandler)
}

/**
 Sends a request to Drupal with an already generated URL

 - parameter path:              The path for the request.
 - parameter method:            The method, eg, GET, POST etc.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func sendRequestWithUrl(_ urlString:String, method:Alamofire.HTTPMethod, params:paramType, completionHandler: completion?) {

    assert(urlString != "", "waterwheel Error: Missing Drupal URL")
    postNotification(waterwheelNotifications.waterwheelDidStartRequest.rawValue, requestName: waterwheelNotificationsTypes.normalRequest.rawValue, object: nil)
    if (waterwheelManager.sharedInstance.signRequestsBasic == true) {

        let plainString = waterwheelManager.sharedInstance.basicUsername + ":" + waterwheelManager.sharedInstance.basicPassword
        let credentialData = plainString.data(using: String.Encoding.utf8)!
        let base64String = credentialData.base64EncodedString(options: NSData.Base64EncodingOptions([]))

        waterwheelManager.sharedInstance.headers["Authorization"] = "Basic \(base64String)"
    }
    if (waterwheelManager.sharedInstance.signCSRFToken == true) {
        waterwheelManager.sharedInstance.headers["X-CSRF-Token"] = waterwheelManager.sharedInstance.CSRFToken
    }
    Alamofire.request(urlString, method: method, parameters: params, encoding:JSONEncoding.default, headers:waterwheelManager.sharedInstance.headers).validate().responseJSON { (response) in
        var responseJSON: JSON
        if response.result.isFailure
        {
            responseJSON = JSON.null
        } else {
            responseJSON = SwiftyJSON.JSON(response.result.value!)
        }
        switch response.result {
        case .success( _):
            completionHandler?(true, response, responseJSON, nil)
        case .failure(let error):
            completionHandler?(false, response, nil, error as NSError?)
        }
        postNotification(waterwheelNotifications.waterwheelDidStartRequest.rawValue, requestName: waterwheelNotificationsTypes.normalRequest.rawValue, object: response.response)
    }
}



// MARK: - GET Requests

/**
 Sends a GET request to Drupal

 - parameter requestPath:       The path for the .GET request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public func get(_ requestPath: String, params: paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .get, params: nil) { (success, response, json, error) in
        completionHandler?(success, response, json, error)
    }
}

/**
 Sends a GET Entity request to Drupal

 - parameter entityType:        The Entity Type to request.
 - parameter entityId:          The entity ID to GET
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public func entityGet(entityType: EntityType, entityId: String, params: paramType, completionHandler: completion?) {
    let requestPath = entityType.rawValue + "/" + entityId
    get(requestPath, params: params, completionHandler: completionHandler)
}


/**
 Sends a GET Node request to Drupal

 - parameter nodeId:            The entity ID to GET
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public func nodeGet(nodeId: String, params: paramType, completionHandler: completion?) {
    entityGet(entityType: .Node, entityId: nodeId, params: params, completionHandler: completionHandler)
}


// MARK: - POST Requests

/**
 Sends a POST request to Drupal

 - parameter requestPath:       The path for the .POST request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public func post(_ requestPath: String, params: paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .post, params: params) { (success, response, json, error) in
        completionHandler?(success, response, json, error)
    }
}

/**
 Sends a POST request to Drupal that will create an Entity

 - parameter entityType:        The Entity Type to request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func entityPost(entityType: EntityType, params: paramType, completionHandler: completion?) {
    let requestPath = "entity/" + entityType.rawValue
    post(requestPath, params: params, completionHandler: completionHandler)
}

/**
 Sends a POST request to Drupal that will create a Node

 - parameter entityId:          The entity ID to GET
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let nodePost: (_ node: paramType, _ completionHandler: completion?) -> Void = { ( params, completionHandler) in
    entityPost(entityType: .Node, params: params, completionHandler: completionHandler)
}

// MARK: - PATCH Requests

/**
 Sends a PATCH request to Drupal

 - parameter requestPath:       The path to patch
 - parameter params:            The object/parameters to send
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response

 */


public func patch(_ requestPath:String, params:paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .patch, params: params) { (success, response, json, error) in
        completionHandler?(success, response, json, error)
    }
}

/**
 Sends a PATCH request to Drupal that will update an Entity

 - parameter entityType:        The Entity Type to request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func entityPatch (entityType: EntityType, entityId:String, params: paramType, completionHandler: completion?) {
    let requestPath = entityType.rawValue + "/" + entityId
    patch(requestPath, params: params, completionHandler: completionHandler)
}


/**
 Sends a PATCH request to Drupal that will update a node

 - parameter nodeId:            The node ID to patch
 - parameter node:              The the updated nodeObject
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func nodePatch (nodeId:String, node: paramType, completionHandler: completion?) {
    entityPatch(entityType: .Node, entityId: nodeId, params: node, completionHandler: completionHandler)
}

// MARK: - DELETE Requests

/**
 Sends a PATCH request to Drupal

 - parameter requestPath:       The path to patch
 - parameter params:            The object/parameters to send
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response

 */


public func delete(_ requestPath:String, params:paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .delete, params: params) { (success, response, json, error) in
        completionHandler?(success, response, json, error)
    }
}

/**
 Sends a DELETE request to Drupal that will delete an Entity

 - parameter entityType:        The Entity Type
 - parameter entityId           The id of the entity
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func entityDelete (entityType: EntityType, entityId:String, params: paramType, completionHandler: completion?) {
    let requestPath = entityType.rawValue + "/" + entityId
    delete(requestPath, params: params, completionHandler: completionHandler)
}

/**
 Sends a DELETE request to Drupal that will delete an Entity

 - parameter entityId           The id of the entity
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func nodeDelete ( nodeId:String, params: paramType,  completionHandler: completion?) {
    entityDelete(entityType: .Node, entityId: nodeId, params: params, completionHandler: completionHandler)
}

/**
 Gets a view response from Drupal

 - parameter viewPath           The path of the view that is set in the views path settings.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func viewGet (viewPath:String, completionHandler: completion?) {
    get(viewPath, params: nil, completionHandler: completionHandler)
}

// MARK: - Helper Functions

/**
 Private function to set Logged in Status
 */
private func setIsLoggedIn(_ isLoggedIn: Bool) {
    waterwheelManager.sharedInstance.isLoggedIn = isLoggedIn
    Defaults[.isLoggedIn] = isLoggedIn
}


/**
 Public function to check if the user is logged in

 */
public func isLoggedIn() -> Bool {
    return waterwheelManager.sharedInstance.isLoggedIn
}

/**
 Private function to set logoutToken
 */
private func setLogoutToken(_ logoutToken: String) {
    waterwheelManager.sharedInstance.logoutToken = logoutToken
    Defaults[.logoutToken] = logoutToken
}

/**
 Private function to set csrf settings
 */
private func setCSRF(_ csrfToken: String, sign: Bool) {
    waterwheelManager.sharedInstance.CSRFToken = csrfToken
    waterwheelManager.sharedInstance.signCSRFToken = sign
    Defaults[.csrfToken] = csrfToken
    Defaults[.signCSRFToken] = sign
}




private func postNotification(_ name: String, requestName: String, object: AnyObject?) {
    var notification = Dictionary<String, AnyObject>()
    notification["name"] = name as AnyObject?
    notification["type"] = requestName as AnyObject?
    notification["object"] = object
    NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: notification)
}
