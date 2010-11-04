//
//  DIOSUser.m
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
#import "DIOSUser.h"


@implementation DIOSUser
-(id) init {
  [super init];
  return self;
}
- (NSDictionary *) loginWithUsername:(NSString*)userName andPassword:(NSString*)password {
  [self setMethod:@"user.login"];
  [self setMethodUrl:@"user/login"];
  [self addParam:userName forKey:@"name"];
  [self addParam:password forKey:@"pass"];
  [self runMethod];
  return [self connResult];
}

- (NSDictionary *) logout {
  [self setMethod:@"user.logout"];
  [self setMethodUrl:@"user/logout"];
  [self runMethod];
  return [self connResult];
}
- (NSDictionary *) userSave:(NSMutableDictionary *)userDict {
  [self setMethod:@"user.save"];
  [self setMethodUrl:@"user"];
  if ([userDict objectForKey:@"uid"] != nil && ![[userDict objectForKey:@"uid"] isEqualToString:@""]) {
    [self setMethodUrl:[NSString stringWithFormat:@"user/%@", [userDict objectForKey:@"uid"]]];
    [self setRequestMethod:@"PUT"];
  }
  for (NSString *key in userDict) {
    [self addParam:[userDict objectForKey:key] forKey:key]; 
  }
  [self runMethod];
  return [self connResult];
}
- (NSDictionary *) userGet:(NSString*)uid {
  [self setMethod:@"user.get"];
  [self setRequestMethod:@"GET"];
  [self setMethodUrl:[NSString stringWithFormat:@"user/%@", uid]];
  [self runMethod];
  
  return [self connResult];
}
- (NSDictionary *) userDelete:(NSString*)uid {
  [self setMethod:@"user.delete"];
  [self setRequestMethod:@"DELETE"];
  [self setMethodUrl:[NSString stringWithFormat:@"user/%@", uid]];
  [self runMethod];
  return [self connResult];
}
@end
