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

public class DIOS {
    static let sharedInstance = DIOS()
    
    let DIOSURLKey = "diosurlkey"
    let plistPath = NSBundle.mainBundle().pathForResource("dios", ofType: "plist")
    let requestFormat = "?_format=json"
    var headers = [
        "Content-Type":"application/json",
        "Accept":"application/json",
    ]
    var URL : String?
    var endpoint : String?
    var basicUsername : String?
    var basicPassword : String?
    var signRequestsBasic : Bool?
    
    public init() {
        self.signRequestsBasic = false
        let dict = NSDictionary(contentsOfFile: plistPath!)
        self.URL =  dict!.objectForKey(self.DIOSURLKey) as? String

    }
    public func setUserNameAndPassword(username:String?, password:String?) {
        self.basicUsername = username
        self.basicPassword = password
        self.signRequestsBasic = true
    }
    public func sendRequest(path:String?, method:Alamofire.Method, params:Dictionary<String, String>?, completionHandler:(success:Bool, response:NSDictionary!, error:NSError!) -> Void) {
        let urlString = self.URL! + "/" + path! + self.requestFormat

        if (self.signRequestsBasic == true) {
            
            let plainString = self.basicUsername! + ":" + self.basicPassword!
            let credentialData = plainString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64String = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions([]))
            
            headers["Authorization"] = "Basic \(base64String)"
        }
        
        Alamofire.request(method, urlString, parameters: params, encoding:.JSON, headers: headers).validate().responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                let response = JSON as! NSDictionary
                completionHandler(success: true, response: response, error: nil)
            case .Failure(let error):
                completionHandler(success: false, response: nil, error: error)
            }
        }
        
    }
    
}
