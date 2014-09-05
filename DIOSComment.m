//
//  DIOSComment.m
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import "DIOSComment.h"
#import "DIOSEntity.h"
#import "DIOSSession.h"
@implementation DIOSComment

+ (void) getCommentWithID:(NSString*)eid
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [DIOSEntity getEntityWithName:@"comment" andID:eid success:success failure:failure];
}

+ (void) createCommentWithParams:(NSDictionary*)params
                      relationID:(NSString*)relationID
                            type:(NSString*)type
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *href = [NSString stringWithFormat:@"%@/rest/type/%@/%@", [[[DIOSSession sharedSession] baseURL] absoluteString], @"comment", type];

    NSString *relationKey = [NSString stringWithFormat:@"%@/rest/relation/comment/comment/entity_id", [[[DIOSSession sharedSession] baseURL] absoluteString]];
    NSString *relationValue = [NSString stringWithFormat:@"%@/node/%@",[[[DIOSSession sharedSession] baseURL] absoluteString],relationID];

    NSDictionary *defaultDict = @{@"_links" : @{@"type" : @{@"href" : href}, relationKey:@[@{@"href" :relationValue}]}, @"entity_id":@[@{@"target_id":relationID,@"revision_id":@""}]};
    [dict addEntriesFromDictionary:defaultDict];
    [dict addEntriesFromDictionary:params];
    NSString *path = [NSString stringWithFormat:@"entity/comment"];
    [[DIOSSession sharedSession] sendRequestWithPath:path method:@"POST" params:dict success:success failure:failure];

}

+ (void) deleteCommentWithID:(NSString*)eid
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [DIOSEntity deleteEntityWithEntityName:@"comment" andID:eid success:success failure:failure];
}

+ (void) patchCommentWithID:(NSString*)eid
                  andParams:(NSDictionary *)params
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [DIOSEntity patchEntityWithEntityName:@"comment" type:@"comment" eid:eid andParams:params success:nil failure:nil];
}
@end
