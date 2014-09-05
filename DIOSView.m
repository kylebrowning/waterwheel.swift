//
//  DIOSView.m
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import "DIOSView.h"
#import "DIOSSession.h"
@implementation DIOSView

+ (void) getViewWithPath:(NSString*)path
                  params:(NSDictionary*)params
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    [[DIOSSession sharedSession] sendRequestWithPath:path method:@"GET" params:params success:success failure:failure];
}
@end
