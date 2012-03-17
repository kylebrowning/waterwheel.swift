//
//  DIOSUser.h
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

#import "AFHTTPRequestOperation.h"
#import "DIOSSession.h"
@protocol DIOSUserDelegate;
@protocol DIOSUserDelegate <NSObject>
- (void)userGetDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;
- (void)userSaveDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;
- (void)userUpdateDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;
- (void)userDeleteDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;
- (void)userIndexDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;
- (void)userLoginDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;
- (void)userLogoutDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error;

@end

@interface DIOSUser : NSObject <DIOSUserDelegate>{
  id <DIOSUserDelegate> delegate;
}
@property (weak, nonatomic) id <DIOSUserDelegate> delegate;
- (id) initWithDelegate:(id<DIOSUserDelegate>)aDelegate;
- (void)userGet:(NSDictionary *)user;
- (void)userSave:(NSDictionary *)user;
- (void)userUpdate:(NSDictionary *)user;
- (void)userDelete:(NSDictionary *)user;
- (void)userIndexWithPage:(NSString *)page fields:(NSString *)fields parameters:(NSArray *)parameteres pageSize:(NSString *)pageSize;
- (void)userIndex:(NSDictionary *)params;
- (void)userLogin:(NSDictionary *)user;
- (void)userLoginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)userLogout;
@end
