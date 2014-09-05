//
//  DIOSView.h
//  dios
//
//  Created by Kyle Browning on 9/5/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
@interface DIOSView : NSObject

+ (void) getViewWithPath:(NSString*)path
                  params:(NSDictionary*)params
                 success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
@end
