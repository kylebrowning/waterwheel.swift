//
//  DIOSUser.m
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import "DIOSUser.h"
#import "DIOSEntity.h"
@implementation DIOSUser

+ (void) getUserWithID:(NSString*)uid
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [DIOSEntity getEntityWithName:@"user" andID:uid success:success failure:failure];
}

+ (void) createUserWithParams:(NSDictionary*)params
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    [DIOSEntity createEntityWithEntityName:@"user" type:@"user" andParams:params success:success failure:failure];
}

+ (void) deleteUserWithID:(NSString*)eid
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [DIOSEntity deleteEntityWithEntityName:@"user" andID:eid success:success failure:failure];
}

+ (void) patchUserWithID:(NSString*)eid
                  params:(NSDictionary*)params
                    type:(NSString *)type
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    [DIOSEntity patchEntityWithEntityName:@"user" type:type eid:eid andParams:params success:success failure:failure];
}
@end
