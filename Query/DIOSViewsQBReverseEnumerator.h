//
//  DIOSViewsQBReverseEnumerator.h
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 1/4/11.
//  Copyright 2011 Avient-Ivy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIOSViewsQB.h"

@interface DIOSViewsQBReverseEnumerator : NSEnumerator {
@private
    DIOSViewsQB *queryBuilder;
    size_t limit;
    size_t offset;
    size_t counter;
}

-(id) initForList:(DIOSViewsQB *) theViewsQB;
-(id) nextObject;
-(id) allObjects;

@property (readwrite, retain, nonatomic) DIOSViewsQB *queryBuilder;

@end
