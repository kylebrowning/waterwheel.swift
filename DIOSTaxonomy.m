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
- (id) init {
  [super init];
  return self;
}
- (NSDictionary *)getTree:(NSString*)vid {
  return [self getTree:vid withParent:nil andMaxDepth:nil];
}
- (NSDictionary *)getTree:(NSString*)vid withParent:(NSString*)parent andMaxDepth:(NSString*)maxDepth {
  [self setMethod:@"taxonomy.getTree"];
  [self setRequestMethod:@"POST"];
  [self setMethodUrl:@"taxonomy_vocabulary/getTree"];
  if (vid != nil) {
    [self addParam:vid forKey:@"vid"];
    
    if (parent != nil) {
      [self addParam:parent forKey:@"parent"];
    }
    if (maxDepth != nil) {
      [self addParam:maxDepth forKey:@"max_depth"];
    }    
    
    [self runMethod];
    
    return [self connResult];
  }
  //vid is required
  return nil;
}
- (NSDictionary *)selectNodes:(NSString*)tid {
  return [self selectNodes:tid andLimit:nil pager:FALSE andOrder:nil];
}
/* 
 * selectNodes
 * see admin/build/services/browse/taxonomy.selectNodes
 * tids and fields should be comma seperated
 */
- (NSDictionary *)selectNodes:(NSString*)tid andLimit:(NSString*)limit pager:(BOOL)pager andOrder:(NSString*)anOrder {
  [self setMethod:@"taxonomy.selectNodes"];
  [self setRequestMethod:@"POST"];
  [self setMethodUrl:@"taxonomy_term/selectNodes"];
  if (tid != nil) {
    [self addParam:tid forKey:@"tid"];

    if (limit != nil) {
      [self addParam:limit forKey:@"depth"];
    }
    if (anOrder != nil) {
      [self addParam:limit forKey:@"order"];
    }
    if (pager == NO) {
      [self addParam:[NSNumber numberWithInt:0]  forKey:@"pager"];
    } else {
      if (pager == YES) {
        [self addParam:[NSNumber numberWithInt:1]  forKey:@"pager"];
      }
    }
    [self runMethod];
    
    return [self connResult];
  }
  //tid is required
  return nil;
}

- (NSDictionary *)getTerm:(NSString*)tid {
    [self setMethod:@"taxonomy_term.get"];
    [self setRequestMethod:@"GET"];
    [self setMethodUrl:[NSString stringWithFormat:@"taxonomy_term/%@", tid]];
    [self runMethod];
    return [self connResult];
}
@end
