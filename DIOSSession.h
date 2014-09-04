//
//  DIOSSession.h
//
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is Kyle Browning, released June 27, 2010.
//
// The Initial Developer of the Original Code is
// Kyle Browning
// Portions created by the Initial Developer are Copyright (C) 2010
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//
// Alternatively, the contents of this file may be used under the terms of
// the GNU General Public License Version 2 or later (the "GPL"), in which
// case the provisions of the GPL are applicable instead of those above. If
// you wish to allow use of your version of this file only under the terms of
// the GPL and not to allow others to use your version of this file under the
// MPL, indicate your decision by deleting the provisions above and replacing
// them with the notice and other provisions required by the GPL. If you do
// not delete the provisions above, a recipient may use your version of this
// file under either the MPL or the GPL.
//
// ***** END LICENSE BLOCK *****

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface DIOSSession : AFHTTPRequestOperationManager {
  NSDictionary *user;
  NSMutableDictionary *accessTokens;
  NSString *consumerKey;
  NSString *consumerSecret;
  NSString *tokenIdentifier;
  NSString *tokenSecret;
}

@property (strong, nonatomic) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *accessTokens;
@property (nonatomic) BOOL signRequests;
@property (nonatomic) BOOL threeLegged;
@property (nonatomic, copy) NSString *realm;
@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;
@property (nonatomic, strong) NSString *tokenIdentifier;
@property (nonatomic, strong) NSString *tokenSecret;
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *endpoint;
@property (nonatomic, strong) NSString *aliasNode;
@property (nonatomic, strong) NSString *aliasComment;
@property (nonatomic, strong) NSString *aliasUser;
@property (nonatomic, strong) NSString *aliasFile;
@property (nonatomic, strong) NSString *aliasViews;
@property (nonatomic, strong) NSString *aliasTaxonomyTerm;
@property (nonatomic, strong) NSString *aliasTaxonomyVocabulary;
@property (nonatomic, strong) NSString *csrfToken;
@property (nonatomic) BOOL systemConnected;
@property (nonatomic, strong) NSMutableArray *timers;
+ (DIOSSession *)setupDios;
+ (DIOSSession *)setupDiosWithURL:(NSString *)url;
+ (DIOSSession *)setupDiosWithURL:(NSString *)url andConsumerKey:(NSString*)aConsumerKey andConsumerSecret:(NSString*)aConsumerSecret;
+ (DIOSSession *)sharedSession;
+ (DIOSSession *)sharedSessionWithURL:(NSString*)url;
+ (DIOSSession *)sharedOauthSessionWithURL:(NSString*)url consumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret;
+ (DIOSSession *)sharedOauthWithConsumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret;

+ (void) getRequestTokensWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

+ (void) getAccessTokensWithRequestTokens:(NSDictionary *)requesTokens
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void) logRequestFailuretoConsole:(AFHTTPRequestOperation *)operation withError:(NSError *)error;
+ (void) logResponseSucccesstoConsole:(AFHTTPRequestOperation *)operation withResponse:(id)responseObject;
- (void) addHeaderValue:(NSString*)value forKey:(NSString*)key;
- (NSMutableURLRequest *) signedRequestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;

- (void) sendSignedRequestWithPath:(NSString*)path
                      method:(NSString*)method
                      params:(NSDictionary*)params
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

- (void) sendUnSignedRequestWithPath:(NSString*)path
                              method:(NSString*)method
                              params:(NSDictionary*)params
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;

- (void) sendRequestWithPath:(NSString*)path
                              method:(NSString*)method
                              params:(NSDictionary*)params
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
+ (void)getCSRFToken;
- (void)getCSRFTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (id) initWithBaseURL:(NSURL *)url consumerKey:(NSString *)consumerKey secret:(NSString *)consumerSecret;
- (void) setAccessToken:(NSString *)accessToken secret:(NSString *)secret;
- (void) setConsumerKey:(NSString *)consumerKey secret:(NSString *)secret;

@end