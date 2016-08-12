//
//  waterwheel.swift
//
//  Created by Kyle Browning on 1/25/16.
//  Copyright © 2016 Kyle Browning. All rights reserved.
//

import Alamofire
import SwiftyJSON

public enum EntityType: String {
    case Node = "node", Comment = "comment"
}

// MARK: - Typelias definitions

public typealias completion = (success:Bool, response:Response<AnyObject, NSError>?, json:SwiftyJSON.JSON?, error:NSError!) -> Void
public typealias stringcompletion = (success:Bool, response:Response<String, NSError>?, json:SwiftyJSON.JSON?, error:NSError!) -> Void
public typealias paramType = [String: AnyObject]?


private let waterwheelErrorString = "waterhwheel error: "

/**
 Responsible for storing state and variables for waterwheel.
 */
public class waterwheelManager {


    // MARK: - Properties

    /**
     A shared instance of `waterwheelManager`
     */
    public static let sharedInstance: waterwheelManager = {
        return waterwheelManager()
    }()

    public let requestFormat = "?_format=json"
    var headers = [
        "Content-Type":"application/json",
        "Accept":"application/json",
        ]
    public var URL : String = ""
    public var basicUsername : String = ""
    public var basicPassword : String = ""
    public var CSRFToken : String = ""
    public var signRequestsBasic : Bool = false
    public var signCSRFToken : Bool = false
    private var isLoggedIn: Bool = false
}


/**
 Sets the URL for all requests to be sent against.
 
 - parameter drupalURL:         The URL for the Drupal Site
 
 */
public func setDrupalURL(drupalURL: String) {
    assert(drupalURL != "", waterwheelErrorString + "Missing Drupal URL")
    waterwheelManager.sharedInstance.URL = drupalURL;
    waterwheel.checkLoginStatus()
}

/** 
 Private function to set Logged in Status
*/
private func setIsLoggedIn(isLoggedIn: Bool) {
    waterwheelManager.sharedInstance.isLoggedIn = isLoggedIn
}

/**
 Public function to check if the user is logged in

 */
public func isLoggedIn() -> Bool {
    return waterwheelManager.sharedInstance.isLoggedIn
}


/**
 Private function to check Login Status with all cookies that have been set.

 */
private func checkLoginStatus() {
    print("Checking login status")
    let urlString = waterwheelManager.sharedInstance.URL + "/user/login_status" + waterwheelManager.sharedInstance.requestFormat
    Alamofire.request(.GET, urlString)
        .validate(statusCode: 200..<300)
        .responseString{ response in
            if (response.result.error == nil) {
                let loginStatus = String(data: response.data!, encoding: NSUTF8StringEncoding)
                if (loginStatus == "1") {
                    waterwheelManager.sharedInstance.isLoggedIn = true
                } else {
                    waterwheelManager.sharedInstance.isLoggedIn = false
                }

            }
            else {
                waterwheelManager.sharedInstance.isLoggedIn = false
            }
    }
}


// MARK: - Authentication methodss

/**
 Allows a username and password to be set for Basic Auth

 - parameter username:          The username to login with.
 - parameter password:          The password to login with

 */
public func setBasicAuthUsernameAndPassword(username:String, password:String) {
    waterwheelManager.sharedInstance.basicUsername = username
    waterwheelManager.sharedInstance.basicPassword = password
    waterwheelManager.sharedInstance.signRequestsBasic = true
    setIsLoggedIn(true)
}


/**
 Login

 - parameter username:          The username to login with.
 - parameter password:          The password to login with
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.


 */
public func login(username:String?, password:String?, completionHandler: stringcompletion?) {
    let urlString = waterwheelManager.sharedInstance.URL + "/user/login" + waterwheelManager.sharedInstance.requestFormat

    assert(username! != "", waterwheelErrorString + "Missing username.")
    assert(password! != "", waterwheelErrorString + "Missing password.")

    let body = [
        "name":username!,
        "pass":password!
    ]

    // POST request to login.
    Alamofire.request(.POST, urlString, headers: waterwheelManager.sharedInstance.headers, parameters: body, encoding: .JSON)
        .validate(statusCode: 200..<300)
        .responseString { response in
            if (response.result.error == nil) {
                waterwheel.setIsLoggedIn(true)
                //We have to get our CSRF token in order to ensure we can make POST, PUT, and DELETE requests.
                getCSRFToken({ (success, response, json, error) in
                    if (success) {
                        completionHandler?(success: true, response: response, json: nil, error: nil)
                    } else {
                        //Failed to get CSRF token for some reason
                        completionHandler?(success: false, response: response, json: nil, error: nil)
                    }
                })
            }
            else {
                waterwheel.setIsLoggedIn(false)
                completionHandler?(success: false, response: response, json: nil, error: response.result.error)
            }
    }
}



/**
 Logout a user

 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func logout(completionHandler completionHandler: stringcompletion?) {
    if waterwheelManager.sharedInstance.signRequestsBasic  {
        waterwheelManager.sharedInstance.basicUsername = ""
        waterwheelManager.sharedInstance.basicPassword = ""
        waterwheelManager.sharedInstance.signRequestsBasic = false
        return
    }
    let urlString = waterwheelManager.sharedInstance.URL + "/user/logout"
    Alamofire.request(.GET, urlString)
        .validate(statusCode: 200..<300)
        .responseString { response in
            if (response.result.error == nil) {
                waterwheelManager.sharedInstance.CSRFToken = ""
                waterwheelManager.sharedInstance.signCSRFToken = false
                waterwheelManager.sharedInstance.isLoggedIn = false
                completionHandler?(success: true, response: response, json: nil, error: response.result.error)
            }
            else {
                completionHandler?(success: false, response: response, json: nil, error: response.result.error)
            }
    }

}

/**
 
 Private function to get the CSRF Token
 
 */
private func getCSRFToken(completionHandler: stringcompletion?) {
    let urlString = waterwheelManager.sharedInstance.URL + "/rest/session/token"
    Alamofire.request(.GET, urlString)
        .validate(statusCode: 200..<300)
        .responseString{ response in
            if (response.result.error == nil) {
                let csrfToken = String(data: response.data!, encoding: NSUTF8StringEncoding)
                waterwheelManager.sharedInstance.CSRFToken = csrfToken!
                waterwheelManager.sharedInstance.signCSRFToken = true
                completionHandler?(success: true, response: response, json: nil, error: nil)
            }
            else {
                completionHandler?(success: false, response: response, json: nil, error: response.result.error)
            }
    }
}

// MARK: - Requests


/**
 Sends a request to Drupal

 - parameter path:              The path for the request.
 - parameter method:            The method, eg, GET, POST etc.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public func sendRequest(path:String, method:Alamofire.Method, params:paramType, completionHandler: completion?) {

    assert(waterwheelManager.sharedInstance.URL != "", "waterwheel Error: Mission Drupal URL")

    let urlString = waterwheelManager.sharedInstance.URL + "/" + path + waterwheelManager.sharedInstance.requestFormat

    if (waterwheelManager.sharedInstance.signRequestsBasic == true) {

        let plainString = waterwheelManager.sharedInstance.basicUsername + ":" + waterwheelManager.sharedInstance.basicPassword
        let credentialData = plainString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64String = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions([]))

        waterwheelManager.sharedInstance.headers["Authorization"] = "Basic \(base64String)"
    }
    if (waterwheelManager.sharedInstance.signCSRFToken == true) {
        waterwheelManager.sharedInstance.headers["X-CSRF-Token"] = waterwheelManager.sharedInstance.CSRFToken
    }
    Alamofire.request(method, urlString, parameters: params, encoding:.JSON, headers:waterwheelManager.sharedInstance.headers).validate().responseSwiftyJSON({ (request, response, json, error) in
        switch response!.result {
        case .Success(let _):
            completionHandler?(success: true, response: response, json: json, error: nil)
        case .Failure(let error):
            completionHandler?(success: false, response: response, json: nil, error: error)
        }
    })
}

// MARK: - GET Requests

/**
 Sends a GET request to Drupal

 - parameter requestPath:       The path for the .GET request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public func get(requestPath: String, params: paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .GET, params: nil) { (success, response, json, error) in
        completionHandler?(success: success, response: response, json: json, error: error)
    }
}

/**
 Sends a GET Entity request to Drupal

 - parameter entityType:        The Entity Type to request.
 - parameter entityId:          The entity ID to GET
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public let entityGet: (entityType: EntityType, entityId: String, params: paramType, completionHandler: completion?) -> Void = { (entityType, entityId, params, completionHandler) in
    let requestPath = entityType.rawValue + "/" + entityId
    get(requestPath, params: params, completionHandler: completionHandler)
}


/**
 Sends a GET Node request to Drupal

 - parameter nodeId:            The entity ID to GET
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public let nodeGet: (nodeId: String, params: paramType, completionHandler: completion?) -> Void = { (nodeId, params, completionHandler) in
    entityGet(entityType: .Node, entityId: nodeId, params: params, completionHandler: completionHandler)
}


// MARK: - POST Requests

/**
 Sends a POST request to Drupal

 - parameter requestPath:       The path for the .POST request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */
public func post(requestPath: String, params: paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .POST, params: params) { (success, response, json, error) in
        completionHandler?(success: success, response: response, json: json, error: error)
    }
}

/**
 Sends a POST request to Drupal that will create an Entity

 - parameter entityType:        The Entity Type to request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let entityPost: (entityType: EntityType, params: paramType, completionHandler: completion?) -> Void = { (entityType, params, completionHandler) in
    let requestPath = "entity/" + entityType.rawValue
    post(requestPath, params: params, completionHandler: completionHandler)
}

/**
 Sends a POST request to Drupal that will create a Node

 - parameter entityId:          The entity ID to GET
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let nodePost: (node: paramType, completionHandler: completion?) -> Void = { ( params, completionHandler) in
    entityPost(entityType: .Node, params: params, completionHandler: completionHandler)
}

// MARK: - PATCH Requests

/**
 Sends a PATCH request to Drupal

 - parameter requestPath:       The path to patch
 - parameter params:            The object/parameters to send
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response

 */


public func patch(requestPath:String, params:paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .PATCH, params: params) { (success, response, json, error) in
        completionHandler?(success: success, response: response, json: json, error: error)
    }
}

/**
 Sends a PATCH request to Drupal that will update an Entity

 - parameter entityType:        The Entity Type to request.
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let entityPatch: (entityType: EntityType, entityId:String, params: paramType, completionHandler: completion?) -> Void = { (entityType, entityId, params, completionHandler) in
    let requestPath = entityType.rawValue + "/" + entityId
    patch(requestPath, params: params, completionHandler: completionHandler)
}


/**
 Sends a PATCH request to Drupal that will update a node

 - parameter nodeId:            The node ID to patch
 - parameter node:              The the updated nodeObject
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let nodePatch: (nodeId:String, node: paramType, completionHandler: completion?) -> Void = { (entityId, params, completionHandler) in
    entityPatch(entityType: .Node, entityId: entityId, params: params, completionHandler: completionHandler)
}

// MARK: - DELETE Requests

/**
 Sends a PATCH request to Drupal

 - parameter requestPath:       The path to patch
 - parameter params:            The object/parameters to send
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response

 */


public func delete(requestPath:String, params:paramType, completionHandler: completion?) {
    sendRequest(requestPath, method: .DELETE, params: params) { (success, response, json, error) in
        completionHandler?(success: success, response: response, json: json, error: error)
    }
}

/**
 Sends a DELETE request to Drupal that will delete an Entity

 - parameter entityType:        The Entity Type
 - parameter entityId           The id of the entity
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let entityDelete: (entityType: EntityType, entityId:String, params: paramType, completionHandler: completion?) -> Void = { (entityType, entityId, params, completionHandler) in
    let requestPath = entityType.rawValue + "/" + entityId
    delete(requestPath, params: params, completionHandler: completionHandler)
}

/**
 Sends a DELETE request to Drupal that will delete an Entity

 - parameter entityId           The id of the entity
 - parameter params:            The parameters for the request.
 - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

 */

public let nodeDelete: (nodeId:String, params: paramType, completionHandler: completion?) -> Void = { (entityId, params, completionHandler) in
   entityDelete(entityType: .Node, entityId: entityId, params: params, completionHandler: completionHandler)
}
