//  DIOSNode.m
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
#import "DIOSNode.h"


@implementation DIOSNode
@synthesize nid, title, body, type;
-(id) init {
    [super init];
    return self;
}

-(id)nodeGet:(NSString *)anNid {
    [self setMethod:@"node.get"];
    [self addParam:anNid forKey:@"nid"];
    [self runMethod];
    return self;
}
-(id)nodeSave {
    [self setMethod:@"node.save"];
    NSMutableDictionary *node = [[NSMutableDictionary alloc] init];
    if(nid != nil) 
    [node setObject:nid forKey:@"nid"];
    if(type != nil)
    [node setObject:type forKey:@"type"];
    if(title != nil)
    [node setObject:title forKey:@"title"];
    if(body != nil)
    [node setObject:body forKey:@"body"];
    
    if([[self userInfo] objectForKey:@"uid"] != nil) {
        id temp = [[self userInfo] objectForKey:@"uid"];
        [node setObject:[temp stringValue] forKey:@"uid"];
    }    
    if([[self userInfo] objectForKey:@"name"] != nil) {
        id temp = [[self userInfo] objectForKey:@"name"];
        [node setObject:temp forKey:@"name"];
    }
    [self addParam:[self serializedObject:node] forKey:@"node"];
    [self runMethod];
    [node release];
    return self;
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

- (void) dealloc {
    [super dealloc];
  
}
@end
