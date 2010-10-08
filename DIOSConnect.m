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
@synthesize connResult, sessid, method, params, userInfo, methodUrl, responseStatusMessage;

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
    NSMutableDictionary *newParams = [[NSMutableDictionary alloc] init];
    params = newParams;
  }
  return self;
}
- (void) connect {
  [self setMethod:@"system.connect"];
  [self setMethodUrl:@"system/connect"];
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

- (NSString*)base64forData:(NSData*)theData {
	
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
  static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
  NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
  uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i;
  for (i=0; i < length; i += 3) {
    NSInteger value = 0;
		NSInteger j;
    for (j = i; j < (i + 3); j++) {
      value <<= 8;
			
      if (j < length) {
        value |= (0xFF & input[j]);
      }
    }
		
    NSInteger theIndex = (i / 3) * 4;
    output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
    output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
    output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
    output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
  }
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
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
  
  NSString *url = [NSString stringWithFormat:@"%@/%@", DRUPAL_SERVICES_URL, [self methodUrl]];
  
  ASIHTTPRequest *requestBinary = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
  NSString *errorStr;
  NSData *dataRep = [NSPropertyListSerialization dataFromPropertyList: [self params]
                                                               format: NSPropertyListBinaryFormat_v1_0
                                                     errorDescription: &errorStr];
  [requestBinary appendPostData:dataRep];
  [requestBinary addRequestHeader:@"Content-Type" value:@"application/plist"];
  [requestBinary addRequestHeader:@"Accept" value:@"application/plist"];
  [requestBinary startSynchronous];
  NSError *error = [requestBinary error];
  NSData *response;
  if (!error) {
    response = [requestBinary responseData];
  }
  NSPropertyListFormat format;
  id plist;
  responseStatusMessage = [requestBinary responseStatusMessage];
  plist = [NSPropertyListSerialization propertyListFromData:response
                                           mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                     format:&format
                                           errorDescription:&errorStr];
  
  

  [self setConnResult:plist];
  if([[self method] isEqualToString:@"system.connect"]) {
    if(plist != nil) {
      [self setSessid:[[plist objectForKey:@"#data"] objectForKey:@"sessid"]];
      [self setUserInfo:[[plist objectForKey:@"#data"]objectForKey:@"user"]];
    }
  }
  if([[self method] isEqualToString:@"user.login"]) {
    if(plist != nil) {
      [self setSessid:[plist objectForKey:@"sessid"]];
      [self setUserInfo:[plist objectForKey:@"user"]];
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

#pragma mark 
#pragma mark DEPRECATED METHODS
// DEPRECATED
- (void) initWithSessId:(NSString*)aSessId {
  NSAssert(NO, @"DIOSConnect initWithSessID is deprecated, use initWithSession");
}
// DEPRECATED
- (void) initWithUserInfo:(NSDictionary*)someUserInfo andSessId:(NSString*)sessId {
  NSAssert(NO, @"DIOSConnect initWithUserInfo is deprecated, use initWithSession");
}
//DEPRECATED -- use DIOSUser
- (void) loginWithUsername:(NSString*)userName andPassword:(NSString*)password {
  NSAssert(NO, @"DIOSConnect loginWithUsername is deprecated, use DIOSUser");
}
//DEPRECATED -- use DIOSUser
- (void) logout {
  NSAssert(NO, @"DIOSConnect logout is deprecated, use DIOSUser");
}

- (void)serializedObject:(NSMutableDictionary *)object {
  NSAssert(NO, @"serializedObject NO LONGER NEEDED");
}
- (void)serializedArray:(NSArray *)array {
  NSAssert(NO, @"serializedArray NO LONGER NEEDED");
}
@end