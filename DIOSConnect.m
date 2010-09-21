//
//  DIOSConnect.m
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
#import <CommonCrypto/CommonHMAC.h> //for kCCHmacAlgSHA256
#import <CommonCrypto/CommonDigest.h> //for CC_SHA256_DIGEST_LENGTH
#import "DIOSConnect.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation DIOSConnect
@synthesize connResult, sessid, method, params, userInfo;

/*
 * This init function will automatically connect and setup the session for communicaiton with drupal
 */
- (id) init {
  [super init];
  isRunning = NO;
  mainTimer = nil;
  if(params == nil) {
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    params = newParams;
  }
  [self connect];
  return self;
}
// DEPRECATED
- (id) initWithSessId:(NSString*)aSessId {
  [super init];
  isRunning = NO;
  mainTimer = nil;
  if(params == nil) {
    NSMutableDictionary *newParams = [[[NSMutableDictionary alloc] init] autorelease];
    params = newParams;
  }
  [self setSessid:aSessId];
  return self;
}
// DEPRECATED
- (id) initWithUserInfo:(NSDictionary*)someUserInfo andSessId:(NSString*)sessId {
  [super init];
  isRunning = NO;
  mainTimer = nil;
  if(params == nil) {
    NSMutableDictionary *newParams = [[[NSMutableDictionary alloc] init] autorelease];
    params = newParams;
  }
  [self setUserInfo:someUserInfo];
  [self setSessid:sessId];
  return self;
}

//Use this, if you have already connected to Drupal, for example, if the user is logged in, you should
//Store that session id somewhere and use it anytime you need to make a new drupal call.
//DIOSConnect should handle there rest.
- (id) initWithSession:(DIOSConnect*)aSession {
  [super init];
  if ([aSession isKindOfClass:[DIOSConnect class]]) {
    [self setUserInfo:[aSession userInfo]];
    [self setSessid:[aSession sessid]];
  }
  isRunning = NO;
  mainTimer = nil;
  if(params == nil) {
    NSMutableDictionary *newParams = [[[NSMutableDictionary alloc] init] autorelease];
    params = newParams;
  }
  return self;
}
- (void) connect {
  [self setMethod:@"system.connect"];
  [self runMethod];
}

- (void) loginWithUsername:(NSString*)userName andPassword:(NSString*)password {
  [self setMethod:@"user.login"];
  [self addParam:userName forKey:@"username"];
  [self addParam:password forKey:@"password"];
  [self runMethod];
}

- (void) logout {
  [self setMethod:@"user.logout"];
  [self runMethod];
}

- (NSString*)stringWithHexBytes:(NSData *)theData {
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([theData length] * 2)];
	const unsigned char *dataBuffer = [theData bytes];
	int i;
	
	for (i = 0; i < [theData length]; ++i)
		[stringBuffer appendFormat:@"%02X", (unsigned long)dataBuffer[ i ]];
	
	return [[stringBuffer copy] autorelease];
}
//This method essetinally converts a node into a serialized array
- (NSString *)serializedObject:(NSMutableDictionary *)object {
  NSString *serializedString;
  if([object isKindOfClass:[NSMutableDictionary class]]) {
    NSEnumerator *e = [object keyEnumerator];
    serializedString = [NSString stringWithFormat:@"a:%d:{", [[e allObjects] count]];
    for(NSString *aKey in object){
      id objectValue = [object valueForKey:aKey];
      NSString *currentReturnValue = nil;
      currentReturnValue = @"";
      if([objectValue isKindOfClass:[NSString class]]) {
        currentReturnValue = [NSString stringWithFormat:@"s:%d:\"%@\";s:%d:\"%@\";", [aKey length], aKey, [objectValue length], objectValue];
      }
      serializedString = [serializedString stringByAppendingString:currentReturnValue];
    }
    serializedString = [serializedString stringByAppendingFormat:@"}"];
  }
  return serializedString;
}

- (NSString *)generateHash:(NSString *)inputString {
	NSData *key = [DRUPAL_API_KEY dataUsingEncoding:NSUTF8StringEncoding];
	NSData *clearTextData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
	uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
	CCHmacContext hmacContext;
	CCHmacInit(&hmacContext, kCCHmacAlgSHA256, key.bytes, key.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
	NSData *hashedData = [NSData dataWithBytes:digest length:32];
	NSString *hashedString = [self stringWithHexBytes:hashedData];
	//NSLog(@"hash string: %@ length: %d",[hashedString lowercaseString],[hashedString length]);
	return [hashedString lowercaseString];
}

-(NSString *) genRandStringLength {
  NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";    
  NSMutableString *randomString = [NSMutableString stringWithCapacity: 10];
  
  for (int i=0; i<10; i++) {
    [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
  }
  
  return randomString;
}

//This runs our method and actually gets a response from drupal
-(void) runMethod {
  NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
  NSString *nonce = [self genRandStringLength];
  //removed because we have to regen this every call
  [self removeParam:@"hash"];
  [self addParam:DRUPAL_DOMAIN forKey:@"domain_name"];
  [self removeParam:@"domain_name"];
  [self removeParam:@"domain_time_stamp"];
  [self removeParam:@"nonce"];
  [self removeParam:@"sessid"];
  NSString *hashParams = [NSString stringWithFormat:@"%@;%@;%@;%@",timestamp,DRUPAL_DOMAIN,nonce,[self method]];
  [self addParam:[self generateHash:hashParams] forKey:@"hash"];
  [self addParam:DRUPAL_DOMAIN forKey:@"domain_name"];
  [self addParam:timestamp forKey:@"domain_time_stamp"];
  [self addParam:nonce forKey:@"nonce"];
  
  [self addParam:[self sessid] forKey:@"sessid"];
  NSURL *url = [NSURL URLWithString:DRUPAL_SERVICES_URL];
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  NSString *key;
  for (key in [self params]) {
    [request setPostValue:[[self params] objectForKey:key] forKey:key];
  }
  [request startSynchronous];
  NSError *error = [request error];
  NSString *response;
  if (!error) {
    response = [request responseString];
  }
  NSDictionary *dictionary;
  @try {
    dictionary = [response propertyList];
  }
  @catch (NSException * e) {
    NSLog(@"I couldnt read the propery list returned from the server %@ :(", response);
  }
  [self setConnResult:dictionary];
  if([[dictionary objectForKey:@"#method"] isEqualToString:@"system.connect"]) {
    myDict = [dictionary objectForKey:@"#data"];
    if(myDict != nil) {
      [self setSessid:[myDict objectForKey:@"sessid"]];
      [self setUserInfo:[myDict objectForKey:@"user"]];
    }
  }
  if([[dictionary objectForKey:@"#method"] isEqualToString:@"user.login"]) {
    myDict = [dictionary objectForKey:@"#data"];
    if(myDict != nil) {
      [self setSessid:[myDict objectForKey:@"sessid"]];
      [self setUserInfo:[myDict objectForKey:@"user"]];
    }
  }
  //Bug in ASIHTTPRequest, put here to stop activity indicator
  UIApplication* app = [UIApplication sharedApplication];
  app.networkActivityIndicatorVisible = NO;
}

- (void) setMethod:(NSString *)aMethod {
  method = aMethod;
  if([params objectForKey:@"method"] == nil) {
    [self addParam:aMethod forKey:@"method"];   
  } else {
    [self removeParam:@"method"];
    [self addParam:aMethod forKey:@"method"];
  }
}
- (NSString *) buildParams {
  NSString *finalParams;
  NSMutableArray *arrayofParams = [[NSMutableArray alloc] init];
  NSEnumerator *enumerator = [params keyEnumerator];
  NSString *aKey = nil;
  NSString *value = nil;
  while ( (aKey = [enumerator nextObject]) != nil) {
    value = [params objectForKey:aKey];
    [arrayofParams addObject:[NSString stringWithFormat:@"&%@=%@", aKey, value]];
  }
  finalParams = [arrayofParams componentsJoinedByString:@""];
  NSString *finalParamsString = @"";
  for (NSString *string in arrayofParams) {
    finalParamsString = [finalParamsString stringByAppendingString:string];
  }
  return finalParams;
}

- (void) addParam:(id)value forKey:(NSString *)key {
  if(value != nil) {
    [params setObject:value forKey:key];
  }
}
- (void) removeParam:(NSString *)key {
  [params removeObjectForKey:key];
}
- (NSString *)description {
  return [NSString stringWithFormat:@"connresult = %@, userInfo = %@, params = %@, sessionid = %@, isRunning = %@", connResult, userInfo, params, sessid, (isRunning ? @"YES" : @"NO")];
}
- (void) dealloc {
  [connResult release];
  [sessid release];
  [method release];
  [params release];
  [userInfo release];
  [super dealloc];
}
@end