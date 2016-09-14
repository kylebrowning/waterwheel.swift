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

//extension DataRequest {
//    /**
//     Adds a handler to be called once the request has finished.
//
//     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
//
//     :returns: The request.
//     */
//    public func responseSwiftyJSON(_ completionHandler: @escaping (DataResponse<Any>) -> Void) -> Self {
//        return responseSwiftyJSON(queue: nil, options:JSONSerialization.ReadingOptions.allowFragments, completionHandler:completionHandler)
//    }
//
//    /// Adds a handler to be called once the request has finished.
//    ///
//    /// - parameter options:           The JSON serialization reading options. Defaults to `.allowFragments`.
//    /// - parameter completionHandler: A closure to be executed once the request has finished.
//    ///
//    /// - returns: The request.
//    @discardableResult
//    public func responseSwiftyJSON(
//        queue: DispatchQueue? = nil,
//        options: JSONSerialization.ReadingOptions = .allowFragments,
//        completionHandler: @escaping (DataResponse<Any>) -> Void)
//        -> Self
//    {
//
//        return response(queue: queue, responseSerializer: DataRequest.jsonResponseSerializer(options: options), completionHandler: { (response) in
//            DispatchQueue.main.async {
//                var responseJSON: JSON
//                if response.result.isFailure
//                {
//                    responseJSON = JSON.null
//                } else {
//                    responseJSON = SwiftyJSON.JSON(response.result.value!)
//                }
//                (queue ?? DispatchQueue.main).async(execute: { 
//                    completionHandler(response.request!, response, responseJSON, response.result.error)
//                })
//            }
//        })
//    }
//}
//extension DataResponse {
//    public var swiftyJSON : JSON
//}
//
//extension Request {
//
//    /**
//     Adds a handler to be called once the request has finished.
//
//     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
//
//     :returns: The request.
//     */
//    public func responseSwiftyJSON(_ completionHandler: (NSURLRequest, DataResponse<AnyObject>, SwiftyJSON.JSON, Error?) -> Void) -> Self {
//        return responseSwiftyJSON(nil, options:JSONSerialization.ReadingOptions.allowFragments, completionHandler:completionHandler)
//    }
//
//    /**
//     Adds a handler to be called once the request has finished.
//
//     :param: queue The queue on which the completion handler is dispatched.
//     :param: options The JSON serialization reading options. `.AllowFragments` by default.
//     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
//
//     :returns: The request.
//     */
//    public func responseSwiftyJSON(
//        queue: DispatchQueue? = nil,
//        options: JSONSerialization.ReadingOptions = .allowFragments,
//        completionHandler: @escaping (DataResponse<Any>) -> Void)
//        -> Self
//    {
//        return response(
//            queue: queue,
//            responseSerializer: DataRequest.jsonResponseSerializer(options: options),
//            completionHandler: completionHandler
//        )
//    }
//    public func responseSwiftyJSON(_ queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments, completionHandler: (NSURLRequest, DataResponse<AnyObject>, JSON, Error?) -> Void) -> Self {
//        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { (response) -> Void in
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                var responseJSON: JSON
//                if response.result.isFailure
//                {
//                    responseJSON = JSON.null
//                } else {
//                    responseJSON = SwiftyJSON.JSON(response.result.value!)
//                }
//                dispatch_async(queue ?? dispatch_get_main_queue(), {
//                    completionHandler(response.request!, response, responseJSON, response.result.error)
//                })
//            })
//        })
//
//    }
//}
