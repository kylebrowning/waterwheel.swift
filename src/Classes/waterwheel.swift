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

/**
 Responsible for storing state and variables for waterwheel.
 */
public class waterwheel {
    // MARK: - Typelias definitions

    public typealias completion = (success:Bool, response:Response<AnyObject, NSError>?, json:SwiftyJSON.JSON?, error:NSError!) -> Void
    public typealias stringcompletion = (success:Bool, response:Response<String, NSError>?, json:SwiftyJSON.JSON?, error:NSError!) -> Void
    public typealias paramType = [String: AnyObject]?

    // MARK: - Properties

    /**
     A shared instance of `waterwheelManager`
     */
    public static let sharedInstance: waterwheel = {
        return waterwheel()
    }()

//    let waterwheelURLKey = "waterwheelurlkey"
//    let plistPath = NSBundle.mainBundle().pathForResource("waterwheel", ofType: "plist")
    public let requestFormat = "?_format=json"
    var headers = [
        "Content-Type":"application/json",
        "Accept":"application/json",
        ]
    public var URL : String
    public let endpoint : String
    public var basicUsername : String
    public var basicPassword : String
    public var CSRFToken : String
    public var signRequestsBasic : Bool = false
    public var signCSRFToken : Bool = false

    // MARK: - Main

    /**
     Initializes the `waterwheel` instance with the our defaults.

     - returns: The new `waterwheel` instance.
     */
    public init() {
        self.URL =  ""
        self.basicUsername = ""
        self.basicPassword = ""
        self.signRequestsBasic = false
        self.CSRFToken = ""
        self.signCSRFToken = false;
        self.endpoint = ""

    }
    /**
     Allows a username and password to be set for Basic Auth
     */
    public func setBasicAuthUsernameAndPassword(username:String, password:String) {
        let waterwheelManager = waterwheel.sharedInstance
        waterwheelManager.basicUsername = username
        waterwheelManager.basicPassword = password
        waterwheelManager.signRequestsBasic = true
    }

    /**
     Login with user-login-form and application/x-www-form-urlencoded
     Since this request is very unique, we customize it here, and this will change when CORE gets a real API login method.

     - parameter username:          The username to login with.
     - parameter entityId:          The password to login with
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.


     */
    public func loginWithUserLoginForm(username:String, password:String, completionHandler:stringcompletion) {
        let waterwheelManager = waterwheel.sharedInstance
        let urlString = waterwheelManager.URL + "/user/login"
        let body = [
            "name":username,
            "pass":password,
            "form_id":"user_login_form",
            ]
        var headers = [
            "Content-Type":"application/x-www-form-urlencoded",
            ]

        // Fetch Request
        Alamofire.request(.POST, urlString, headers: headers, parameters: body, encoding: .URL)
            .validate(statusCode: 200..<300)
            .responseString { response in
                if (response.result.error == nil) {
                    waterwheelManager.getCSRFToken({ (success, response, json, error) in
                        if (success) {
                            completionHandler(success: true, response: response, json: nil, error: nil)
                        } else {
                            //Failed to get CSRF token for some reason
                            completionHandler(success: false, response: response, json: nil, error: nil)
                        }
                    })
                }
                else {
                    completionHandler(success: false, response: response, json: nil, error: response.result.error)
                }
        }
    }

    /**
     Logout a user
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.


     */

    public func logout(completionHandler:stringcompletion) {
        let waterwheelManager = waterwheel.sharedInstance
        let urlString = waterwheelManager.URL + "/user/logout"
        Alamofire.request(.GET, urlString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if (response.result.error == nil) {
                    debugPrint("HTTP Response Body: \(response.data)")
                }
                else {
                    debugPrint("HTTP Request failed: \(response.result.error)")
                }
        }

    }


    public func getCSRFToken(completionHandler:stringcompletion) {
        let waterwheelManager = waterwheel.sharedInstance
        let urlString = waterwheelManager.URL + "/rest/session/token"
        Alamofire.request(.GET, urlString)
            .validate(statusCode: 200..<300)
            .responseString{ response in
                if (response.result.error == nil) {
                    let csrfToken = String(data: response.data!, encoding: NSUTF8StringEncoding)
                    waterwheelManager.CSRFToken = csrfToken!
                    waterwheelManager.signCSRFToken = true
                    completionHandler(success: true, response: response, json: nil, error: nil)
                }
                else {
                    completionHandler(success: false, response: response, json: nil, error: response.result.error)
                }
        }
    }

    // MARK: - Requests

    public func sendRequest(path:String, method:Alamofire.Method, params:paramType, completionHandler:completion) {
        let waterwheelManager = waterwheel.sharedInstance

        let urlString = waterwheelManager.URL + "/" + path + self.requestFormat

        if (waterwheelManager.signRequestsBasic == true) {

            let plainString = waterwheelManager.basicUsername + ":" + waterwheelManager.basicPassword
            let credentialData = plainString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64String = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions([]))

            headers["Authorization"] = "Basic \(base64String)"
        }
        if (waterwheelManager.signCSRFToken == true) {
            headers["X-CSRF-Token"] = waterwheelManager.CSRFToken
        }
        Alamofire.request(method, urlString, parameters: params, encoding:.JSON, headers:headers).validate().responseSwiftyJSON({ (request, response, json, error) in
            switch response!.result {
            case .Success(let _):
                completionHandler(success: true, response: response, json: json, error: nil)
            case .Failure(let error):
                completionHandler(success: false, response: response, json: nil, error: error)
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
    public func get(requestPath: String, params: paramType, completionHandler:completion) {
        self.sendRequest(requestPath, method: .GET, params: nil) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }


    /**
     Sends a GET Entity request to Drupal

     - parameter entityType:        The Entity Type to request.
     - parameter entityId:          The entity ID to GET
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */
    public let entityGet: (entityType: EntityType, entityId: String, params: paramType, completionHandler: completion) -> Void = { (entityType, entityId, params, completionHandler) in
        let requestPath = entityType.rawValue + "/" + entityId
        waterwheel.sharedInstance.get(requestPath, params: params, completionHandler: completionHandler)
    }


    /**
     Sends a GET Node request to Drupal

     - parameter nodeId:            The entity ID to GET
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */
    public let nodeGet: (nodeId: String, params: paramType, completionHandler:completion) -> Void = { (nodeId, params, completionHandler) in
        waterwheel.sharedInstance.entityGet(entityType: EntityType.Node, entityId: nodeId, params: params, completionHandler: completionHandler)
    }


    // MARK: - POST Requests

    /**
     Sends a POST request to Drupal

     - parameter requestPath:       The path for the .POST request.
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */
    public func post(requestPath: String, params: paramType, completionHandler:completion) {
        self.sendRequest(requestPath, method: .POST, params: params) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }

    /**
     Sends a POST request to Drupal that will create an Entity

     - parameter entityType:        The Entity Type to request.
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */

    public let entityPost: (entityType: EntityType, params: paramType, completionHandler: completion) -> Void = { (entityType, params, completionHandler) in
        let requestPath = "entity/" + entityType.rawValue
        waterwheel.sharedInstance.post(requestPath, params: params, completionHandler: completionHandler)
    }

    /**
     Sends a POST request to Drupal that will create a Node

     - parameter entityId:          The entity ID to GET
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */

    public let nodePost: (node: paramType, completionHandler: completion) -> Void = { ( params, completionHandler) in
        waterwheel.sharedInstance.entityPost(entityType: .Node, params: params, completionHandler: completionHandler)
    }

    // MARK: - PATCH Requests

    /**
     Sends a PATCH request to Drupal

     - parameter requestPath:       The path to patch
     - parameter params:            The object/parameters to send
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */


    public func patch(requestPath:String, params:paramType, completionHandler:completion) {
        self.sendRequest(requestPath, method: .PATCH, params: params) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }

    /**
     Sends a PATCH request to Drupal that will update an Entity

     - parameter entityType:        The Entity Type to request.
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */

    public let entityPatch: (entityType: EntityType, entityId:String, params: paramType, completionHandler: completion) -> Void = { (entityType, entityId, params, completionHandler) in
        let requestPath = entityType.rawValue + "/" + entityId
        waterwheel.sharedInstance.patch(requestPath, params: params, completionHandler: completionHandler)
    }


    /**
     Sends a PATCH request to Drupal that will update a node

     - parameter nodeId:            The node ID to patch
     - parameter node:              The the updated nodeObject
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */

    public let nodePatch: (nodeId:String, node: paramType, completionHandler: completion) -> Void = { (entityId, params, completionHandler) in
        waterwheel.sharedInstance.entityPatch(entityType: .Node, entityId: entityId, params: params, completionHandler: completionHandler)
    }

    // MARK: - DELETE Requests

    /**
     Sends a PATCH request to Drupal

     - parameter requestPath:       The path to patch
     - parameter params:            The object/parameters to send
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */


    public func delete(requestPath:String, params:paramType, completionHandler:completion) {
        self.sendRequest(requestPath, method: .DELETE, params: params) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }

    /**
     Sends a DELETE request to Drupal that will delete an Entity

     - parameter entityType:        The Entity Type
     - parameter entityId           The id of the entity
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */

    public let entityDelete: (entityType: EntityType, entityId:String, params: paramType, completionHandler: completion) -> Void = { (entityType, entityId, params, completionHandler) in
        let requestPath = entityType.rawValue + "/" + entityId
        waterwheel.sharedInstance.delete(requestPath, params: params, completionHandler: completionHandler)
    }

    /**
     Sends a DELETE request to Drupal that will delete an Entity

     - parameter entityId           The id of the entity
     - parameter params:            The parameters for the request.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */

    public let nodeDelete: (nodeId:String, params: paramType, completionHandler: completion) -> Void = { (entityId, params, completionHandler) in
        waterwheel.sharedInstance.entityDelete(entityType: .Node, entityId: entityId, params: params, completionHandler: completionHandler)
    }
    
}