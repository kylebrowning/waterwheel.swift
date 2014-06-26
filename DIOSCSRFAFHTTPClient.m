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
    [self.operationQueue addOperation:operation];
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  [self getCSRFTokenWithSuccess:^(NSString *csrfToken) {
      NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
    [request setValue: csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
      [self.operationQueue addOperation:operation];
  } failure:^(AFHTTPRequestOperation *csrfOperation, NSError *error) {
      NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:path parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
      [self.operationQueue addOperation:operation];
  }];
}

- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  [self getCSRFTokenWithSuccess:^(NSString *csrfToken) {
      NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:path parameters:parameters error:nil];
    [request setValue: csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
      [self.operationQueue addOperation:operation];
  } failure:^(AFHTTPRequestOperation *csrfOperation, NSError *error) {
      NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:path parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
      [self.operationQueue addOperation:operation];
  }];
}

- (void)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
  [self getCSRFTokenWithSuccess:^(NSString *csrfToken) {
      NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:path parameters:parameters error:nil];
    [request setValue: csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
      [self.operationQueue addOperation:operation];
  } failure:^(AFHTTPRequestOperation *csrfOperation, NSError *error) {
      NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:path parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
      [self.operationQueue addOperation:operation];
  }];
}

@end