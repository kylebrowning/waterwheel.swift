//
//  DIOSCSRFAFHTTPClient.m
//  WalkthroughAcquia
//
//  Created by Zoltán Váradi on 7/3/13.
//  Copyright (c) 2013 Zoltán Váradi. All rights reserved.
//

#import "DIOSCSRFAFHTTPClient.h"
#import "Settings.h"

@implementation DIOSCSRFAFHTTPClient

- (NSString*)getCSRFToken
{
  NSString* csrfToken;
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/services/session/token", kDiosBaseUrl]]];
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
  csrfToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  
  return csrfToken;
}

-(void)getCSRFTokenWithSuccess:(void (^)(NSString *csrfToken))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/services/session/token", kDiosBaseUrl]]];
  AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *csrfToken = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    success(csrfToken);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(operation, error);
  }];
  [self enqueueHTTPRequestOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  [self getCSRFTokenWithSuccess:^(NSString *csrfToken) {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [request setValue: csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
  } failure:^(AFHTTPRequestOperation *csrfOperation, NSError *error) {
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
  }];
}

- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  [self getCSRFTokenWithSuccess:^(NSString *csrfToken) {
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    [request setValue: csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
  } failure:^(AFHTTPRequestOperation *csrfOperation, NSError *error) {
    NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
  }];
}

- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  [self getCSRFTokenWithSuccess:^(NSString *csrfToken) {
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    [request setValue: csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
  } failure:^(AFHTTPRequestOperation *csrfOperation, NSError *error) {
    NSURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
  }];
}

@end