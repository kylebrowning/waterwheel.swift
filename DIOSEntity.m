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
@end
