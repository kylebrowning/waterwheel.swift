//
//  DIOSComment.m
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


#import "DIOSComment.h"

@implementation DIOSComment
@synthesize delegate = _delegate;
- (id) init {
  self = [super init];
  if (!self) {
    return nil;
  }
  [self setDelegate:self];
  return self;
}
- (id) initWithDelegate:(id<DIOSCommentDelegate>)aDelegate {
  self = [super init];
  if (!self) {
    return nil;
  }
  [self setDelegate:aDelegate];
  return self;
}

#pragma mark CommentGets
- (void)commentGet:(NSDictionary *)comment {
  [[DIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseComment, [comment objectForKey:@"cid"]] parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(commentGetDidFinish:operation:response:error:)]) {
      [_delegate commentGetDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this get so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(commentGetDidFinish:operation:response:error:)]) {
      [_delegate commentGetDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this get so my response will never be used.", _delegate);
    }
  }];
}
- (void)commentGetDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  DIOSSession *session = [DIOSSession sharedSession];
  [[session delegate] callDidFinish:status operation:operation response:response error:error];
}

#pragma mark commentSaves
- (void)commentSave:(NSDictionary *)comment {
  [[DIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@", kDiosEndpoint, kDiosBaseComment] parameters:comment success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(commentSaveDidFinish:operation:response:error:)]) {
      [_delegate commentSaveDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this post so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(commentSaveDidFinish:operation:response:error:)]) {
      [_delegate commentSaveDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this post so my response will never be used.", _delegate);
    }
  }];
}
- (void)commentSaveDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}

#pragma mark commentUpdate
- (void)commentUpdate:(NSDictionary *)comment {
  [[DIOSSession sharedSession] putPath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseComment, [comment objectForKey:@"cid"]] parameters:comment success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(commentUpdateDidFinish:operation:response:error:)]) {
      [_delegate commentUpdateDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this put so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(commentUpdateDidFinish:operation:response:error:)]) {
      [_delegate commentUpdateDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this put so my response will never be used.", _delegate);
    }
  }];
}
- (void)commentUpdateDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}

#pragma mark CommentDelete
- (void)commentDelete:(NSDictionary *)comment {
  [[DIOSSession sharedSession] deletePath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseComment, [comment objectForKey:@"cid"]] parameters:comment success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(commentDeleteDidFinish:operation:response:error:)]) {
      [_delegate commentDeleteDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this delete so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(commentDeleteDidFinish:operation:response:error:)]) {
      [_delegate commentDeleteDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this delete so my response will never be used.", _delegate);
    }
  }];
}
- (void)commentDeleteDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}

#pragma mark commentIndex
//Simpler method if you didnt want to build the params :)
- (void)commentIndexWithPage:(NSString *)page fields:(NSString *)fields parameters:(NSArray *)parameteres pageSize:(NSString *)pageSize {
  NSMutableDictionary *commentIndexDict = [NSMutableDictionary new];
  [commentIndexDict setValue:page forKey:@"page"];
  [commentIndexDict setValue:fields forKey:@"fields"];
  [commentIndexDict setValue:parameteres forKey:@"parameters"];
  [commentIndexDict setValue:pageSize forKey:@"pagesize"];  
  [self commentIndex:commentIndexDict];
}

- (void)commentIndex:(NSDictionary *)params {
  [[DIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@", kDiosEndpoint, kDiosBaseComment] parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(commentIndexDidFinish:operation:response:error:)]) {
      [_delegate commentIndexDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this delete so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(commentIndexDidFinish:operation:response:error:)]) {
      [_delegate commentIndexDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this delete so my response will never be used.", _delegate);
    }
  }];
}
- (void)commentIndexDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}
@end