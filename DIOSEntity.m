//
//  DIOSEntity.m
//  dios
//
//  Created by Kyle Browning on 9/4/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import "DIOSEntity.h"
#import "DIOSSession.h"
@implementation DIOSEntity

+ (void) getEntityWithName:(NSString*)name andID:(NSString*)eid
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    NSString *path = [NSString stringWithFormat:@"%@/%@", name, eid];
    [[DIOSSession sharedSession] sendRequestWithPath:path method:@"GET" params:nil success:success failure:failure];
}

+ (void) createEntityWithEntityName:(NSString*)name
                              type:(NSString*)type
                         andParams:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *href = [NSString stringWithFormat:@"%@/rest/type/%@/%@", [[[DIOSSession sharedSession] baseURL] absoluteString], name, type];
    NSDictionary *defaultDict = @{@"_links" : @{@"type" : @{@"href" : href}}};
    [dict addEntriesFromDictionary:defaultDict];
    [dict addEntriesFromDictionary:params];
    NSString *path = [NSString stringWithFormat:@"entity/%@", name];
    [[DIOSSession sharedSession] sendRequestWithPath:path method:@"POST" params:dict success:success failure:failure];
}
+ (void) deleteEntityWithEntityName:(NSString*)name andID:(NSString*)eid
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    NSString *path = [NSString stringWithFormat:@"%@/%@", name, eid];
    [[DIOSSession sharedSession] sendRequestWithPath:path method:@"DELETE" params:nil success:success failure:failure];
}

+ (void) patchEntityWithEntityName:(NSString*)name
                              type:(NSString*)type
                               eid:(NSString*)eid
                         andParams:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *href = [NSString stringWithFormat:@"%@/rest/type/%@/%@", [[[DIOSSession sharedSession] baseURL] absoluteString], name, type];
    NSDictionary *defaultDict = @{@"_links" : @{@"type" : @{@"href" : href}}};
    [dict addEntriesFromDictionary:defaultDict];
    [dict addEntriesFromDictionary:params];
    NSString *path = [NSString stringWithFormat:@"%@/%@", name, eid];
    [[DIOSSession sharedSession] sendRequestWithPath:path method:@"PATCH" params:dict success:success failure:failure];
}
@end
