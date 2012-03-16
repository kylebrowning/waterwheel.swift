//
//  DIOSTaxonomy.m
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

#import "DIOSTaxonomy.h"

@implementation DIOSTaxonomy
@synthesize delegate = _delegate;
- (id) init {
  self = [super init];
  if (!self) {
    return nil;
  }
  [self setDelegate:self];
  return self;
}
- (id) initWithDelegate:(id<DIOSTaxonomyDelegate>)aDelegate {
  self = [super init];
  if (!self) {
    return nil;
  }
  [self setDelegate:aDelegate];
  return self;
}

- (void)getTreeWithVid:(NSString *)vid withParent:(NSString *)parent andMaxDepth:(NSString *)maxDepth {
  NSMutableDictionary *params = [NSMutableDictionary new];
  [params setValue:vid forKey:@"vid"];
  [params setValue:parent forKey:@"parent"];
  [params setValue:maxDepth forKey:@"max_depth"];
  [self getTreeWithParams:params];
}
- (void)getTreeWithParams:(NSDictionary *)params {
  [[DIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@/getTree", kDiosEndpoint, kDiosBaseTaxonmyVocabulary] parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(getTreeDidFinish:operation:response:error:)]) {
      [_delegate getTreeDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this post so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(getTreeDidFinish:operation:response:error:)]) {
      [_delegate getTreeDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this post so my response will never be used.", _delegate);
    }
  }];
}
- (void)selectNodesWithTid:(NSString *)tid andLimit:(NSString *)limit andPager:(NSString *)pager andOrder:(NSString *)order {
  NSMutableDictionary *params = [NSMutableDictionary new];
  [params setValue:tid forKey:@"tid"];
  [params setValue:limit forKey:@"limit"];
  [params setValue:pager forKey:@"pager"];
  [params setValue:order forKey:@"prder"];
  [self selectNodesWithParams:params];
}
- (void)selectNodesWithParams:(NSDictionary *)params {
  [[DIOSSession sharedSession] postPath:[NSString stringWithFormat:@"%@/%@/selectNodes", kDiosEndpoint, kDiosBaseTaxonmyTerm] parameters:params success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(selectNodesDidFinish:operation:response:error:)]) {
      [_delegate selectNodesDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this post so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(selectNodesDidFinish:operation:response:error:)]) {
      [_delegate selectNodesDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this post so my response will never be used.", _delegate);
    }
  }];
}
- (void)getTermWithTid:(NSString *)tid {
  [[DIOSSession sharedSession] getPath:[NSString stringWithFormat:@"%@/%@/%@", kDiosEndpoint, kDiosBaseTaxonmyTerm, tid] parameters:nil success:^(__unused AFHTTPRequestOperation *operation, id JSON) {
    if ([_delegate respondsToSelector:@selector(getTreeDidFinish:operation:response:error:)]) {
      [_delegate getTreeDidFinish:YES operation:operation response:JSON error:nil];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this get so my response will never be used.", _delegate);
    }
  } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
    if ([_delegate respondsToSelector:@selector(getTreeDidFinish:operation:response:error:)]) {
      [_delegate getTreeDidFinish:NO operation:operation response:nil error:error];
    } else {
      DLog(@"I couldnt find the delegate and one was set %@ for this get so my response will never be used.", _delegate);
    }
  }];
}
- (void)getTreeDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}
- (void)selectNodesDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}
- (void)getTermDidFinish:(BOOL)status operation:(AFHTTPRequestOperation *)operation response:(id)response error:(NSError*)error {
  [[[DIOSSession sharedSession] delegate] callDidFinish:status operation:operation response:response error:error];
}
@end
