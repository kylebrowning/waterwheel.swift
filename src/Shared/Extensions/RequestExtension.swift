//
//  RequestExtension.swift
//  
//
//  Created by Kyle Browning on 7/13/16.
//
//

import Foundation
import Alamofire
import SwiftyJSON

extension Request {

    /**
     Adds a handler to be called once the request has finished.

     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.

     :returns: The request.
     */
    public func responseSwiftyJSON(completionHandler: (NSURLRequest, Response<AnyObject, NSError>?, SwiftyJSON.JSON, ErrorType?) -> Void) -> Self {
        return responseSwiftyJSON(nil, options:NSJSONReadingOptions.AllowFragments, completionHandler:completionHandler)
    }

    /**
     Adds a handler to be called once the request has finished.

     :param: queue The queue on which the completion handler is dispatched.
     :param: options The JSON serialization reading options. `.AllowFragments` by default.
     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.

     :returns: The request.
     */
    public func responseSwiftyJSON(queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, Response<AnyObject, NSError>?, JSON, ErrorType?) -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { (response) -> Void in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var responseJSON: JSON
                if response.result.isFailure
                {
                    responseJSON = JSON.null
                } else {
                    responseJSON = SwiftyJSON.JSON(response.result.value!)
                }
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completionHandler(response.request!, response, responseJSON, response.result.error)
                })
            })
        })

    }
}
