//
//  DIOSNodeQB.m
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 12/23/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "DIOSNode.h"
#import "DIOSNodeQB.h"
#import "IPhoneAflickaAppDelegate.h"

@implementation DIOSNodeQB

+(NSDictionary *) nodeDataForNid:(NSNumber *) aNid
{
    DIOSNode *nodeQB = (DIOSNode *) [(IPhoneAflickaAppDelegate *) [[UIApplication sharedApplication] delegate] nodeQB];
    
    // this is an autoreleased object
    return [[[nodeQB nodeGet:[aNid stringValue]] connResult] objectForKey:@"#data"];
}

@end
