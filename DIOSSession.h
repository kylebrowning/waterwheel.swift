//
//  DIOSSession.h
//  dios
//
//  Created by Kyle Browning on 9/4/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface DIOSSession : AFHTTPRequestOperationManager {

}
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic) BOOL signRequests;
@property (nonatomic, strong) NSString *basicAuthUsername;
@property (nonatomic, strong) NSString *basicAuthPassword;

+ (DIOSSession *) sharedSession;
- (void) sendRequestWithPath:(NSString*)path
                      method:(NSString*)method
                      params:(NSDictionary*)params
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

- (NSMutableURLRequest *) requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters;

+ (void) logResponseSucccessToConsole:(AFHTTPRequestOperation *)operation withResponse:(id)responseObject;
+ (void) logRequestFailuretoConsole:(AFHTTPRequestOperation *)operation withError:(NSError *)error;
- (void) setBasicAuthCredsWithUsername:(NSString *)username andPassword:(NSString*)password;
@end
