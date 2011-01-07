//
//  DIOSViewsQR.h
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 1/3/11.
//  Copyright 2011 Avient-Ivy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIOSViewsQB.h"

@interface DIOSViewsQBEnumerator : NSEnumerator {
@private
    DIOSViewsQB *queryBuilder;
    size_t limit;
    size_t offset;
    size_t counter; 
}

-(id) initForList:(DIOSViewsQB *) theViewsQB;
-(id) initForList:(DIOSViewsQB *) theViewsQB withOffset:(size_t) off andLimit: (size_t) lim;

-(id) nextObject;
-(id) allObjects;

@property (readwrite, retain, nonatomic) DIOSViewsQB *queryBuilder;

@end
