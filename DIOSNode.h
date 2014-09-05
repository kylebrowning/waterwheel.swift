//
//  DIOSNode.h
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
@interface DIOSNode : NSObject
+ (void) getNodeWithID:(NSString*)eid
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) createNodeWithParams:(NSDictionary*)params
                         type:(NSString *)type
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
@end
