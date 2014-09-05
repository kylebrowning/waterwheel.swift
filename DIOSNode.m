//
//  DIOSNode.m
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import "DIOSNode.h"
#import "DIOSEntity.h"

@implementation DIOSNode
+ (void) getNodeWithID:(NSString*)eid
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [DIOSEntity getEntityWithName:@"node" andID:eid success:success failure:failure];
}
+ (void) createNodeWithParams:(NSDictionary*)params
                         type:(NSString *)type
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    [DIOSEntity creatEntityWithEntityName:@"node" type:type andParams:params success:success failure:failure];
}
@end
