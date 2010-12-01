//
//  DIOSConnect.h
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

@interface DIOSConnect : NSObject {
  NSDictionary *connResult;
  NSMutableDictionary *params;
  NSDictionary *myDict;
  NSString *sessid;
  NSString *method;
  NSDictionary *userInfo;
  BOOL isRunning;
  NSTimer *mainTimer;
  NSString *methodUrl;
  NSString *responseStatusMessage;
  NSString *requestMethod;
  NSError *error;
  id progressDelegate;
}
@property (nonatomic, retain) NSDictionary *connResult;
@property (nonatomic, retain) id progressDelegate;
@property (nonatomic, retain) NSString *sessid;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSDictionary *userInfo;
@property (nonatomic, retain) NSString *methodUrl;
@property (nonatomic, retain) NSString *responseStatusMessage;
@property (nonatomic, retain) NSString *requestMethod;
@property (nonatomic, readonly) NSError *error;

- (id) init;
- (void) initWithSessId:(NSString*)aSessId;
- (void) initWithUserInfo:(NSDictionary*)someUserInfo andSessId:(NSString*)sessId;
- (void) runMethod;
- (void) addParam:(id)value forKey:(NSString *)key;
- (void) removeParam:(NSString *)key;
- (void) connect;
- (NSDictionary *) loginWithUsername:(NSString*)userName andPassword:(NSString*)password;
- (NSDictionary *) logout;
- (void) connect;
- (NSString *) buildParams;
- (NSString *) genRandStringLength;
- (NSString *)generateHash:(NSString *)inputString;
- (void)serializedObject:(NSMutableDictionary *)object;
- (void)serializedArray:(NSArray *)array;
- (id) initWithSession:(DIOSConnect*)aSession;
@end
