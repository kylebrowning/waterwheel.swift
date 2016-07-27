//
//  DIOS.swift
//  Drupal Publisher
//
//  Created by Kyle Browning on 1/25/16.
//  Copyright © 2016 Kyle Browning. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



/**
 Responsible for storing state and variables for DIOS.
 */
public class DIOS {
    // MARK: - Typelias definitions

    public typealias completion = (success:Bool, response:Response<AnyObject, NSError>?, json:SwiftyJSON.JSON?, error:NSError!) -> Void
    public typealias stringcompletion = (success:Bool, response:Response<String, NSError>?, json:SwiftyJSON.JSON?, error:NSError!) -> Void
    public typealias paramType = [String: AnyObject]?

    // MARK: - Properties
    
    /**
     A shared instance of `DIOSManager`
     */
    public static let sharedInstance: DIOS = {
        return DIOS()
    }()
    
    let DIOSURLKey = "diosurlkey"
    let plistPath = NSBundle.mainBundle().pathForResource("dios", ofType: "plist")
    public let requestFormat = "?_format=json"
    var headers = [
        "Content-Type":"application/json",
        "Accept":"application/json",
        ]
    public let URL : String
    public let endpoint : String
    public var basicUsername : String
    public var basicPassword : String
    public var CSRFToken : String
    public var signRequestsBasic : Bool = false
    public var signCSRFToken : Bool = false
    
    // MARK: - Main
    
    /**
     Initializes the `DIOSManager` instance with the our defaults.
     
     - returns: The new `DIOSManager` instance.
     */
    public init() {
        let dict = NSDictionary(contentsOfFile: plistPath!)
        self.URL =  (dict!.objectForKey(self.DIOSURLKey) as? String)!
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
        let diosManager = DIOS.sharedInstance
        diosManager.basicUsername = username
        diosManager.basicPassword = password
        diosManager.signRequestsBasic = true
    }

    /**
     Login with user-login-form and application/x-www-form-urlencoded
     Since this request is very unique, we customize it here, and this will change when CORE gets a real API login method.

     - parameter username:          The username to login with.
     - parameter entityId:          The password to login with
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.


     */
    public func loginWithUserLoginForm(username:String, password:String, completionHandler:stringcompletion) {
        let diosManager = DIOS.sharedInstance
        let urlString = diosManager.URL + "/user/login"
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
                    diosManager.getCSRFToken({ (success, response, json, error) in
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
        let urlString = diosManager.URL + "/user/logout"
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


    private func getCSRFToken(completionHandler:stringcompletion) {
        let diosManager = DIOS.sharedInstance
        let urlString = diosManager.URL + "/rest/session/token"
        Alamofire.request(.GET, urlString)
            .validate(statusCode: 200..<300)
            .responseString{ response in
                if (response.result.error == nil) {
                    let csrfToken = String(data: response.data!, encoding: NSUTF8StringEncoding)
                    diosManager.CSRFToken = csrfToken!
                    diosManager.signCSRFToken = true
                    completionHandler(success: true, response: response, json: nil, error: nil)
                }
                else {
                    completionHandler(success: false, response: response, json: nil, error: response.result.error)
                }
        }
    }

    // MARK: - Requests

    public func sendRequest(path:String, method:Alamofire.Method, params:paramType, completionHandler:completion) {
        let diosManager = DIOS.sharedInstance
        
        let urlString = diosManager.URL + "/" + path + self.requestFormat

        if (diosManager.signRequestsBasic == true) {
            
            let plainString = diosManager.basicUsername + ":" + diosManager.basicPassword
            let credentialData = plainString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64String = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions([]))
            
            headers["Authorization"] = "Basic \(base64String)"
        }
        if (diosManager.signCSRFToken == true) {
            headers["X-CSRF-Token"] = diosManager.CSRFToken
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
}


// MARK: - DIOSEntity

/**
 Responsible for all Entity Operations
 */
public class DIOSEntity : DIOS {
    
    // MARK: - Entity Requests  to Drupal
    
    /**
     Sends a GET request to Drupal that will return an entity
     
     - parameter entityType:        The entity name, eg "node".
     - parameter entityId:          The ID of the entity to get.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response.

     */
    public func get(entityType:String, entityId:String, completionHandler:completion) {
        let requestPath = entityType + "/" + entityId
        self.sendRequest(requestPath, method: .GET, params: nil) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }

    /**
     Sends a POST request to Drupal that will create an entity

     - parameter entityType:        The entity name, eg "node".
     - parameter params:            The object/parameters to send
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */
    public func create(entityType:String, params:paramType, completionHandler:completion) {
        post(entityType, params: params, completionHandler: completionHandler)
    }

    /**
     Sends a POST request to Drupal that will create an entity

     - parameter entityType:        The entity name, eg "node".
     - parameter params:            The object/parameters to send
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */

    public func post(entityType:String, params:paramType, completionHandler:completion) {
        let requestPath = "entity/" + entityType

        self.sendRequest(requestPath, method: .POST, params: params) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }

    /**
     Sends a PATCH request to Drupal that will update an entity

     - parameter entityType:        The entity name, eg "node".
     - parameter params:            The object/parameters to send
     - parameter entityId:          The ID of the entity to get.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */

    public func put(entityType:String, entityId:String, params:paramType, completionHandler:completion) {
        patch(entityType, entityId: entityId, params: params, completionHandler: completionHandler)
    }

    /**
     Sends a PATCH request to Drupal that will update an entity

     - parameter entityType:        The entity name, eg "node".
     - parameter params:            The object/parameters to send
     - parameter entityId:          The ID of the entity to get.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */


    public func patch(entityType:String, entityId:String, params:paramType, completionHandler:completion) {
        let requestPath = entityType + "/" + entityId

        self.sendRequest(requestPath, method: .PATCH, params: params) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }

    /**
     Sends a DELETE request to Drupal that will delete an entity

     - parameter entityType:        The entity name, eg "node".
     - parameter entityId:          The ID of the entity to get.
     - parameter completionHandler: A completion handler that your delegate method should call if you want the response

     */

    public func delete(entityType:String, entityId:String, completionHandler:completion) {
        let requestPath = entityType + "/" + entityId

        self.sendRequest(requestPath, method: .DELETE, params: nil) { (success, response, json, error) in
            completionHandler(success: success, response: response, json: json, error: error)
        }
    }
}
