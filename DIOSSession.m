//
//  DIOSSession.m
//  dios
//
//  Created by Kyle Browning on 9/4/14.
//  Copyright (c) 2014 Kyle Browning. All rights reserved.
//

#import "DIOSSession.h"

@implementation DIOSSession
@synthesize baseURL;

#pragma mark Singleton Methods

+ (DIOSSession *) sharedSession
{
    static DIOSSession *sharedSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSession = [[self alloc] init];
        sharedSession.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    return sharedSession;
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

#pragma mark -
#pragma mark Request Methods
- (void) sendRequestWithPath:(NSString*)path
                      method:(NSString*)method
                      params:(NSDictionary*)params
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure
{
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:params];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [DIOSSession logResponseSucccessToConsole:operation withResponse:responseObject];
        if (success != nil) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DIOSSession logRequestFailuretoConsole:operation withError:error];
        if (failure != nil) {
            failure(operation, error);
        }
    }];
    if (_signRequests) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:_basicAuthUsername password:_basicAuthPassword persistence:NSURLCredentialPersistenceNone];
        [operation setCredential:credential];
    }
    [self.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *) requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters
{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", [[self baseURL] absoluteString], path];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/hal+json" forHTTPHeaderField:@"Content-Type"];

    if (self.signRequests) {
        //doesntwork
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:_basicAuthUsername password:_basicAuthPassword];
    }
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:urlString parameters:parameters error:nil];
    return request;
}

#pragma mark -
#pragma mark Logging methods
+ (void) logResponseSucccessToConsole:(AFHTTPRequestOperation *)operation withResponse:(id)responseObject
{
#ifdef DEBUG
    NSLog(@"\n----- DIOS Success -----\nStatus code: %ld\nURL: %@\n----- Response ----- \n%@\n", (long)operation.response.statusCode, [operation.response.URL absoluteString],operation.responseString);
#endif
}
+ (void) logRequestFailuretoConsole:(AFHTTPRequestOperation *)operation withError:(NSError *)error
{
#ifdef DEBUG
    NSString *body = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:4];
    
    NSLog(@"\n----- DIOS Failure -----\nStatus code: %ld\nRequest : %@\nURL: %@\n----- Response ----- \n%@\n----- Error ----- \n%@", (long)operation.response.statusCode, body, [operation.response.URL absoluteString], operation.responseString, [error localizedDescription]);
#endif
}

#pragma mark -
#pragma mark Helpful methods
- (void) setBasicAuthCredsWithUsername:(NSString *)username andPassword:(NSString*)password {
    [self setBasicAuthUsername:username];
    [self setBasicAuthPassword:password];
    [self setSignRequests:YES];
}
@end
