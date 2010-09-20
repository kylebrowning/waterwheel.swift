//
//  DIOSViews.h
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
- (id) init {
    [super init];
    return self;
}

- (void) getComments:(NSString*)nid andStart:(NSString *)start andCount:(NSString *)count {
    [self setMethod:@"comment.loadNodeComments"];
    [self addParam:nid forKey:@"nid"];
    [self addParam:start forKey:@"start"];
    [self addParam:count forKey:@"count"];
    [self runMethod];
}
- (void) addComment:(NSString*)nid subject:(NSString*)aSubject body:(NSString*)aBody {
    [self setMethod:@"comment.save"];
    NSMutableDictionary *comment = [[NSMutableDictionary alloc] init];
    if(nid != nil) 
      [comment setObject:nid forKey:@"nid"];
    if(aSubject != nil)
      [comment setObject:aSubject forKey:@"subject"];
    if(aBody != nil)
      [comment setObject:aBody forKey:@"comment"];
    
    if([[self userInfo] objectForKey:@"uid"] != nil) {
      id temp = [[self userInfo] objectForKey:@"uid"];
      [comment setObject:[temp stringValue] forKey:@"uid"];
    }    
    if([[self userInfo] objectForKey:@"name"] != nil) {
      id temp = [[self userInfo] objectForKey:@"name"];
      [comment setObject:temp forKey:@"name"];
    }
    [self addParam:[self serializedObject:comment] forKey:@"comment"];
    [self addParam:nid forKey:@"nid"];
    [self runMethod];
    [comment release];
    return;
}
@end
