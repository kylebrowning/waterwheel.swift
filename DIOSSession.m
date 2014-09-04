//
//  DIOSSession.m
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

#import "DIOSSession.h"
#import "DIOSSystem.h"
#import "AFHTTPRequestOperation.h"
#include <sys/time.h>
#import <CommonCrypto/CommonHMAC.h>

static NSString* Base64EncodedStringFromData(NSData *data);
static NSString* URLEncodeString(NSString *string);
static const NSString *kOAuthSignatureMethodKey = @"oauth_signature_method";
static const NSString *kOAuthVersionKey = @"oauth_version";
static const NSString *kOAuthConsumerKey = @"oauth_consumer_key";
static const NSString *kOAuthTokenIdentifier = @"oauth_token";
static const NSString *kOAuthSignatureKey = @"oauth_signature";

static const NSString *kOAuthSignatureTypeHMAC_SHA1 = @"HMAC-SHA1";
static const NSString *kOAuthVersion1_0 = @"1.0";
static const NSString *kDiosOptionsSiteUrlKey = @"siteUrl";
static const NSString *kDiosOptionsEndpointKey = @"endpoint";
static const NSString *kDiosOptionsAliasNodeKey = @"aliasNode";
static const NSString *kDiosOptionsAliasCommentKey = @"aliasComment";
static const NSString *kDiosOptionsAliasUserKey = @"aliasUser";
static const NSString *kDiosOptionsAliasFileKey = @"aliasFile";
static const NSString *kDiosOptionsAliasViewsKey = @"aliasViews";
static const NSString *kDiosOptionsAliasTaxonomyTermKey = @"aliasTaxonomyTerm";
static const NSString *kDiosOptionsAliasTaxonomyVocabularyKey = @"aliasTaxonomyVocabulary";

static dispatch_once_t once;
static DIOSSession *sharedSession;

@interface DIOSSession()

- (id) initWithBaseURL:(NSURL *)url;
- (void) addGeneratedTimestampAndNonceInto:(NSMutableDictionary *)dictionary;

- (NSString *) authorizationHeaderValueForRequest:(NSMutableURLRequest *)request;
@end

@implementation DIOSSession

@synthesize user, accessTokens, consumerKey, consumerSecret, tokenIdentifier, tokenSecret, baseURL,
realm, signRequests, threeLegged, endpoint, aliasNode, aliasComment, aliasUser, aliasFile, aliasViews,
aliasTaxonomyTerm, aliasTaxonomyVocabulary, csrfToken, systemConnected, timers;


+ (DIOSSession *)setupDios {
    [DIOSSystem systemConnectwithSuccess:nil failure:nil];
    return [DIOSSession sharedSession];
}
+ (DIOSSession *)setupDiosWithURL:(NSString *)url {
    DIOSSession *sharedSession = [DIOSSession sharedSessionWithURL:url];
    [DIOSSystem systemConnectwithSuccess:nil failure:nil];
    return sharedSession;
}
+ (DIOSSession *)setupDiosWithURL:(NSString *)url andConsumerKey:(NSString*)aConsumerKey andConsumerSecret:(NSString*)aConsumerSecret {
    DIOSSession *sharedSession = [DIOSSession sharedOauthSessionWithURL:url consumerKey:aConsumerKey secret:aConsumerSecret];
    [DIOSSystem systemConnectwithSuccess:nil failure:nil];
    return sharedSession;
}

+ (DIOSSession *)sharedSession {
    dispatch_once(&once, ^ {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dios" ofType:@"plist"];
        NSMutableDictionary *diosOptions = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        NSString *url = [diosOptions objectForKey:kDiosOptionsSiteUrlKey];
        sharedSession = [[self alloc] initWithBaseURL:[NSURL URLWithString:url]];
        [sharedSession setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [sharedSession setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [sharedSession setBaseURL:[NSURL URLWithString:url]];
        [sharedSession checkOptionsAndSetDefaultsWithSession:sharedSession];
    });
    return sharedSession;
}

+ (DIOSSession *)sharedSessionWithURL:(NSString*)url {
  dispatch_once(&once, ^ {
    sharedSession = [[self alloc] initWithBaseURL:[NSURL URLWithString:url]];
    sharedSession.requestSerializer = [AFJSONRequestSerializer serializer];
    sharedSession.responseSerializer = [AFJSONResponseSerializer serializer];
  });
    [sharedSession setBaseURL:[NSURL URLWithString:url]];
    [sharedSession checkOptionsAndSetDefaultsWithSession:sharedSession];
  return sharedSession;
}

+ (DIOSSession *)sharedOauthSessionWithURL:(NSString*)url consumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret {
  dispatch_once(&once, ^ {
    sharedSession = [[self alloc] initWithBaseURL:[NSURL URLWithString:url] consumerKey:aConsumerKey secret:aConsumerSecret];
    sharedSession.requestSerializer = [AFJSONRequestSerializer serializer];
    sharedSession.responseSerializer = [AFJSONResponseSerializer serializer];
  });
  [sharedSession checkOptionsAndSetDefaultsWithSession:sharedSession];
  return sharedSession;
}
+ (DIOSSession *)sharedOauthWithConsumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret {
    dispatch_once(&once, ^ {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dios" ofType:@"plist"];
        NSMutableDictionary *diosOptions = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        NSString *url = [diosOptions objectForKey:kDiosOptionsSiteUrlKey];
        sharedSession = [[self alloc] initWithBaseURL:[NSURL URLWithString:url] consumerKey:aConsumerKey secret:aConsumerSecret];
        sharedSession.requestSerializer = [AFJSONRequestSerializer serializer];
        sharedSession.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    [sharedSession checkOptionsAndSetDefaultsWithSession:sharedSession];
    return sharedSession;
}

+ (void) getRequestTokensWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  
  DIOSSession *client = [[DIOSSession alloc] initWithBaseURL:[[DIOSSession sharedSession] baseURL]];
  [client setConsumerKey:[[DIOSSession sharedSession] consumerKey] secret:[[DIOSSession sharedSession] consumerSecret]];
    
  //[client registerHTTPOperationClass:[AFHTTPRequestOperation class]];

  [sharedSession.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Accept"];
  [sharedSession.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];

  NSMutableDictionary *params = [NSMutableDictionary new];
  [params setObject:[[DIOSSession sharedSession] consumerKey] forKey:kOAuthConsumerKey];
  [params setObject:[[DIOSSession sharedSession] consumerSecret] forKey:kOAuthTokenIdentifier];
  [client sendSignedRequestWithPath:@"/oauth/request_token" method:@"GET" params:params success:success failure:failure];
}


+ (void) getAccessTokensWithRequestTokens:(NSDictionary *)requestTokens
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

  DIOSSession *client = [[DIOSSession alloc] initWithBaseURL:[[DIOSSession sharedSession] baseURL]];
  [client setConsumerKey:[[DIOSSession sharedSession] consumerKey] secret:[[DIOSSession sharedSession] consumerSecret]];
    
  //[client registerHTTPOperationClass:[AFHTTPRequestOperation class]];

  [sharedSession.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Accept"];
  [sharedSession.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    
  [client setAccessToken:[requestTokens objectForKey:@"oauth_token"] secret:[requestTokens objectForKey:@"oauth_token_secret"]];
  [client sendSignedRequestWithPath:@"/oauth/access_token" method:@"GET" params:requestTokens success:success failure:failure];
}

+ (void)getCSRFToken {
    DIOSSession *sharedSession = [DIOSSession sharedSession];
    [sharedSession getCSRFTokenWithSuccess:nil failure:nil];
}
- (void)getCSRFTokenWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/services/session/token", [[DIOSSession sharedSession] baseURL]]]];
    [request setValue:[NSString stringWithFormat:@"text/plain"] forHTTPHeaderField:@"Accept"];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *aCsrfToken = [NSString stringWithUTF8String:[responseObject bytes]];
        [[DIOSSession sharedSession] setCsrfToken:aCsrfToken];
        if (success != nil) {
            success(operation, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DIOSSession logRequestFailuretoConsole:operation withError:error];

    }];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"application/json", nil];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
}

- (void) sendSignedRequestWithPath:(NSString*)path
                            method:(NSString*)method
                            params:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
  NSMutableURLRequest *request = [self signedRequestWithMethod:method path:path parameters:params];
  [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
  if (csrfToken != nil) {
        [request setValue:csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
  }
  AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    if ([self systemConnected] || ([path rangeOfString:@"system/connect"].location != NSNotFound)) {
        [self.operationQueue addOperation:operation];
    } else {
        NSMutableDictionary *temp = [NSMutableDictionary new];
        [temp setValue:success forKey:@"success"];
        [temp setValue:request forKey:@"request"];
        [temp setValue:failure forKey:@"failure"];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(tryOperationAgainAfterSystemConnect:)
                                                        userInfo:temp
                                                         repeats:YES];
        [timers addObject:timer];
    }
}
- (void) sendUnSignedRequestWithPath:(NSString*)path
                            method:(NSString*)method
                            params:(NSDictionary*)params
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:params];
    [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Accept"];
    if (csrfToken != nil) {
        [request setValue:csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
    }
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];

    if ([self systemConnected] || ([path rangeOfString:@"system/connect"].location != NSNotFound)) {
        [self.operationQueue addOperation:operation];
    } else {
        NSMutableDictionary *temp = [NSMutableDictionary new];
        [temp setValue:success forKey:@"success"];
        [temp setValue:request forKey:@"request"];
        [temp setValue:failure forKey:@"failure"];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(tryOperationAgainAfterSystemConnect:)
                                                        userInfo:temp
                                                         repeats:YES];
        [timers addObject:timer];
    }
}
- (void) tryOperationAgainAfterSystemConnect:(NSTimer *)theTimer {
    if ([self systemConnected] && [timers count] != 0) {
        NSUInteger index = [timers indexOfObject:theTimer];
        NSTimer *timerInArray =[timers objectAtIndex:index];
        id userInfo = [timerInArray userInfo];
        NSMutableURLRequest *request = [userInfo objectForKey:@"request"];
        void(^success)() = [userInfo objectForKey:@"success"];
        void(^failure)() = [userInfo objectForKey:@"failure"];
        if (csrfToken != nil) {
            [request setValue:csrfToken forHTTPHeaderField:@"X-CSRF-Token"];
        }
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
        [self.operationQueue addOperation:operation];
        [timerInArray invalidate];
        [timers removeObjectAtIndex:index];
    }
}
- (void) sendRequestWithPath:(NSString*)path
              method:(NSString*)method
              params:(NSDictionary*)params
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {

    if(self.signRequests) {
        [self sendSignedRequestWithPath:path method:method params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [DIOSSession logResponseSucccesstoConsole:operation withResponse:responseObject];
            if (success != nil) {
                success(operation, responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [DIOSSession logRequestFailuretoConsole:operation withError:error];
            if (failure != nil) {
                failure(operation, error);
            }
        }];
    } else {
        [self sendUnSignedRequestWithPath:path method:method params:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [DIOSSession logResponseSucccesstoConsole:operation withResponse:responseObject];
            if (success != nil) {
                success(operation, responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [DIOSSession logRequestFailuretoConsole:operation withError:error];
            if (failure != nil) {
                failure(operation, error);
            }
        }];
    }
}
+ (void) logResponseSucccesstoConsole:(AFHTTPRequestOperation *)operation withResponse:(id)responseObject {
#ifdef DEBUG
    NSLog(@"\n----- DIOS Success -----\nStatus code: %ld\nURL: %@\n----- Response ----- \n%@\n", (long)operation.response.statusCode, [operation.response.URL absoluteString],operation.responseString);
#endif
}
+ (void) logRequestFailuretoConsole:(AFHTTPRequestOperation *)operation withError:(NSError *)error {
    #ifdef DEBUG
    NSLog(@"\n----- DIOS Failure -----\nStatus code: %ld\nURL: %@\n----- Response ----- \n%@\n----- Error ----- \n%@", (long)operation.response.statusCode, [operation.response.URL absoluteString], operation.responseString, [error localizedDescription]);
    #endif
}
- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
    //[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
    
    [sharedSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [sharedSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
  return self;
}

- (id) initWithBaseURL:(NSURL *)url consumerKey:(NSString *)aConsumerKey secret:(NSString *)aConsumerSecret {
  self = [super initWithBaseURL:url];

  if (self) {
    self.signRequests = YES;
    self.consumerKey = aConsumerKey;
    self.consumerSecret = aConsumerSecret;

    //[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
      
      [sharedSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
      [sharedSession.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  }

  return self;
}
- (NSMutableURLRequest *) signedRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
  NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", [[self baseURL] absoluteString], [self endpoint], path];
  NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:urlString parameters:parameters error:nil];
  [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  NSString *authorizationHeader = [self authorizationHeaderValueForRequest:request];
  [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];

  return request;
}
- (NSMutableURLRequest *) requestWithMethod:(NSString *)method
                                       path:(NSString *)path
                                 parameters:(NSDictionary *)parameters {

  NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", [[self baseURL] absoluteString], [self endpoint], path];
 [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:urlString parameters:parameters error:nil];

  if (self.signRequests) {
    NSString *authorizationHeader = [self authorizationHeaderValueForRequest:request];
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
  }

  return request;
}

- (void) setAccessToken:(NSString *)accessToken secret:(NSString *)secret {
  self.signRequests = YES;
  self.tokenIdentifier = accessToken;
  self.tokenSecret = secret;
  self.threeLegged = YES;
}

- (void) setConsumerKey:(NSString *)aConsumerKey secret:(NSString *)secret {
  self.signRequests = YES;    
  self.consumerKey = aConsumerKey;
  self.consumerSecret = secret;
}
- (void) addHeaderValue:(NSString*)value forKey:(NSString*)key {
  [sharedSession.requestSerializer setValue:value forHTTPHeaderField:key];
}

- (NSMutableDictionary *) mutableDictionaryWithOAuthInitialData {
  NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 kOAuthSignatureTypeHMAC_SHA1, kOAuthSignatureMethodKey,
                                 kOAuthVersion1_0, kOAuthVersionKey,
                                 nil];

  if (self.consumerKey) [result setObject:self.consumerKey forKey:kOAuthConsumerKey];
  if (self.tokenIdentifier) [result setObject:self.tokenIdentifier forKey:kOAuthTokenIdentifier];

  [self addGeneratedTimestampAndNonceInto:result];

  return  result;
}
- (void) checkOptionsAndSetDefaultsWithSession:(DIOSSession *) session {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dios" ofType:@"plist"];
    NSMutableDictionary *diosOptions = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSString *diosOptionsAliasNode = [diosOptions objectForKey:kDiosOptionsAliasNodeKey];
    if (diosOptionsAliasNode != nil) {
        //Set loaded alias
        [session setAliasNode:diosOptionsAliasNode];
    } else {
        //Set Default alias for node resource
        [session setAliasNode:@"node"];
    }

    NSString *diosOptionsAliasComment = [diosOptions objectForKey:kDiosOptionsAliasCommentKey];
    if (diosOptionsAliasComment != nil) {
        //Set loaded alias
        [session setAliasComment:diosOptionsAliasComment];
    } else {
        //Set Default alias for comment resource
        [session setAliasComment:@"comment"];
    }
    NSString *diosOptionsAliasUser = [diosOptions objectForKey:kDiosOptionsAliasUserKey];
    if (diosOptionsAliasUser != nil) {
        //Set loaded alias
        [session setAliasUser:diosOptionsAliasUser];
    } else {
        //Set Default alias for User resource
        [session setAliasUser:@"user"];
    }

    NSString *diosOptionsAliasFile = [diosOptions objectForKey:kDiosOptionsAliasFileKey];
    if (diosOptionsAliasFile != nil) {
        //Set loaded alias
        [session setAliasFile:diosOptionsAliasFile];
    } else {
        //Set Default alias for File resource
        [session setAliasFile:@"file"];
    }

    NSString *diosOptionsAliasViews = [diosOptions objectForKey:kDiosOptionsAliasViewsKey];
    if (diosOptionsAliasViews != nil) {
        //Set loaded alias
        [session setAliasViews:diosOptionsAliasViews];
    } else {
        //Set Default alias for Views resource
        [session setAliasViews:@"views"];
    }

    NSString *diosOptionsAliasTaxonomyTerm = [diosOptions objectForKey:kDiosOptionsAliasTaxonomyTermKey];
    if (diosOptionsAliasTaxonomyTerm != nil) {
        //Set loaded alias
        [session setAliasTaxonomyTerm:diosOptionsAliasTaxonomyTerm];
    } else {
        //Set Default alias for TaxonomyTerm resource
        [session setAliasTaxonomyTerm:@"taxonomy_term"];
    }

    NSString *diosOptionsAliasTaxonomyVocabulary = [diosOptions objectForKey:kDiosOptionsAliasTaxonomyVocabularyKey];
    if (diosOptionsAliasTaxonomyVocabulary != nil) {
        //Set loaded alias
        [session setAliasTaxonomyVocabulary:diosOptionsAliasTaxonomyVocabulary];
    } else {
        //Set Default alias for TaxonomyVocabulary resource
        [session setAliasTaxonomyVocabulary:@"taxonomy_vocabulary"];
    }

    NSString *diosOptionsEndpoint = [diosOptions objectForKey:kDiosOptionsEndpointKey];
    if (diosOptionsEndpoint != nil) {
        //Set loaded endpoint
        [session setEndpoint:diosOptionsEndpoint];
    } else {
        //Set Default endpoint
        [session setEndpoint:@"api"];
    }

    NSString *diosOptionsConsumerKey = [diosOptions objectForKey:kOAuthConsumerKey];
    if (diosOptionsConsumerKey != nil) {
        //Set loaded consumerKey
        [session setConsumerKey:diosOptionsConsumerKey];
    }
    NSString *diosOptionsConsumerSecret = [diosOptions objectForKey:kOAuthTokenIdentifier];
    if (diosOptionsConsumerSecret != nil) {
        //Set loaded consumerSecret
        [session setConsumerSecret:diosOptionsConsumerSecret];
    }
    //If we have both a consumer key and secret we should sign the requests.
    if(diosOptionsConsumerKey != nil && diosOptionsConsumerSecret != nil) {
        [self setSignRequests:YES];
    }
    [self setTimers:[NSMutableArray new]];
#ifdef DEBUG
    NSLog(@"options that were found and set : %@", diosOptions);
#endif
}
- (NSString *) stringWithOAuthParameters:(NSMutableDictionary *)oauthParams requestParameters:(NSDictionary *)parameters {
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:oauthParams];
  [params addEntriesFromDictionary:parameters];

  // sorting parameters
  NSArray *sortedKeys = [[params allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
    NSComparisonResult result = [key1 compare:key2 options:NSLiteralSearch];
    if (result == NSOrderedSame)
      result = [[params objectForKey:key1] compare:[params objectForKey:key2] options:NSLiteralSearch];

    return result;
  }];

  // join keys and values with =
  NSMutableArray *longListOfParameters = [NSMutableArray arrayWithCapacity:[sortedKeys count]];
  [sortedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
    [longListOfParameters addObject:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
  }];

  // join components with &
  return [longListOfParameters componentsJoinedByString:@"&"];
}

- (NSString *) authorizationHeaderValueForRequest:(NSMutableURLRequest *)request {
  NSURL *url = request.URL;
  NSString *fixedURL = [self baseURLforAddress:url];
  NSMutableDictionary *oauthParams = [self mutableDictionaryWithOAuthInitialData];
  // adding oauth_ extra params to the header
  NSArray *parameterComponents = [[request.URL query] componentsSeparatedByString:@"&"];
  NSMutableDictionary *parameters = [NSMutableDictionary new];
  for(NSString *component in parameterComponents) {
    NSArray *subComponents = [component componentsSeparatedByString:@"="];
    if ([subComponents count] == 2) {
      [parameters setObject:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
    }
  }
  NSData *body = [request HTTPBody];
  NSString *htttpBody = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
  NSArray *subComponents = [htttpBody componentsSeparatedByString:@"="];
  if ([subComponents count] == 2) {
    [parameters setObject:[subComponents objectAtIndex:1] forKey:[subComponents objectAtIndex:0]];
  }

  NSString *allParameters = [self stringWithOAuthParameters:oauthParams requestParameters:parameters];
  // adding HTTP method and URL
  NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", [request.HTTPMethod uppercaseString], URLEncodeString(fixedURL), URLEncodeString(allParameters)];

  NSString *signature = [self signatureForBaseString:signatureBaseString];

  // add to OAuth params
  [oauthParams setObject:signature forKey:kOAuthSignatureKey];

  // build OAuth Authorization Header
  NSMutableArray *headerParams = [NSMutableArray arrayWithCapacity:[oauthParams count]];
  [oauthParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
    [headerParams addObject:[NSString stringWithFormat:@"%@=\"%@\"", key, URLEncodeString(obj)]];
  }];

  // let's use the base URL if a realm was not set
  NSString *oauthRealm = self.realm;
  if (!oauthRealm) oauthRealm = [self baseURLforAddress:[self baseURL]];

  NSString *result = [NSString stringWithFormat:@"OAuth realm=\"%@\",%@", oauthRealm, [headerParams componentsJoinedByString:@","]];

  return result;
}

- (void)addGeneratedTimestampAndNonceInto:(NSMutableDictionary *)dictionary {
  NSUInteger epochTime = (NSUInteger)[[NSDate date] timeIntervalSince1970];
  NSString *timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)epochTime];
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  NSString *nonce = (NSString *)CFBridgingRelease(string);
  CFRelease(theUUID);

  [dictionary setObject:nonce forKey:@"oauth_nonce"];
  [dictionary setObject:timestamp forKey:@"oauth_timestamp"];
}

- (NSString *) signatureForBaseString:(NSString *)baseString {
  NSString *key = [NSString stringWithFormat:@"%@&%@", self.consumerSecret != nil ? URLEncodeString(self.consumerSecret) : @"", self.tokenSecret != nil ? URLEncodeString(self.tokenSecret) : @""];
  const char *keyBytes = [key cStringUsingEncoding:NSUTF8StringEncoding];
  const char *baseStringBytes = [baseString cStringUsingEncoding:NSUTF8StringEncoding];
  unsigned char digestBytes[CC_SHA1_DIGEST_LENGTH];

  CCHmac(kCCHmacAlgSHA1, keyBytes, strlen(keyBytes), baseStringBytes, strlen(baseStringBytes), digestBytes);

  NSData *digestData = [NSData dataWithBytes:digestBytes length:CC_SHA1_DIGEST_LENGTH];
  return Base64EncodedStringFromData(digestData);
}

- (NSString *) baseURLforAddress:(NSURL *)url {
  NSAssert1([url host] != nil, @"URL host missing: %@", [url absoluteString]);

  // Port need only be present if it's not the default
  NSString *hostString;
  if (([url port] == nil)
      || ([[[url scheme] lowercaseString] isEqualToString:@"http"] && ([[url port] integerValue] == 80))
      || ([[[url scheme] lowercaseString] isEqualToString:@"https"] && ([[url port] integerValue] == 443))) {
    hostString = [[url host] lowercaseString];
  } else {
    hostString = [NSString stringWithFormat:@"%@:%@", [[url host] lowercaseString], [url port]];
  }

  return [NSString stringWithFormat:@"%@://%@%@", [[url scheme] lowercaseString], hostString, [[url absoluteURL] path]];
}

//
//  The function below is based on
//
//  NSString+URLEncode.h
//
//  Created by Scott James Remnant on 6/1/11.
//  Copyright 2011 Scott James Remnant <scott@netsplit.com>. All rights reserved.
//
static NSString *URLEncodeString(NSString *string) {
  // See http://en.wikipedia.org/wiki/Percent-encoding and RFC3986
  // Hyphen, Period, Understore & Tilde are expressly legal
  const CFStringRef legalURLCharactersToBeEscaped = CFSTR(":/=,!$&'()*+;[]@#?");

  return ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, ( CFStringRef)string, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8));
}
@end
// The function below was inspired on
//
// AFOAuth2Client.m
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
static NSString * Base64EncodedStringFromData(NSData *data) {
  NSUInteger length = [data length];
  NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];

  uint8_t *input = (uint8_t *)[data bytes];
  uint8_t *output = (uint8_t *)[mutableData mutableBytes];

  for (NSUInteger i = 0; i < length; i += 3) {
    NSUInteger value = 0;
    for (NSUInteger j = i; j < (i + 3); j++) {
      value <<= 8;
      if (j < length) value |= (0xFF & input[j]);
    }

    static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    NSUInteger idx = (i / 3) * 4;
    output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
    output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
    output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
    output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
  }

  return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}
