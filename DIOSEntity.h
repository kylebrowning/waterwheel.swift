//
//  DIOSEntity.h
//  dios
//
//  Created by Kyle Browning on 9/4/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
@interface DIOSEntity : NSObject

+ (void) getEntityWithName:(NSString*)name andID:(NSString*)eid
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) creatEntityWithEntityName:(NSString*)name
                              type:(NSString*)type
                         andParams:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
@end
