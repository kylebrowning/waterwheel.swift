//
//  DIOSComment.h
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
@interface DIOSComment : NSObject

+ (void) getCommentWithID:(NSString*)eid
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) createCommentWithParams:(NSDictionary*)params
                      relationID:(NSString*)relationID
                            type:(NSString*)type
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) deleteCommentWithID:(NSString*)eid
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) patchCommentWithID:(NSString*)eid
                  andParams:(NSDictionary *)params
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
@end
