//
//  DIOSViewsQBReverseEnumerator.m
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 1/4/11.
//  Copyright 2011 Avient-Ivy. All rights reserved.
//

#import "DIOSViewsQBReverseEnumerator.h"

@implementation DIOSViewsQBReverseEnumerator

@synthesize queryBuilder;

-(id) initForList:(DIOSViewsQB *)theViewsQB withOffset:(size_t)off andLimit:(size_t)lim
{
    if ((self = [super init]))   {
        self.queryBuilder = theViewsQB;
        limit = lim;
        offset = off;
        counter = off + 1;  // increment by one so 0 tests for end
    }
    
    return self;
}

-(id) initForList:(DIOSViewsQB *) theViewsQB
{
    // iterate backwards through all
    [self initForList:theViewsQB withOffset:([theViewsQB countResultsWithOffset:0 andLimit:0] - 1) andLimit:0];
    
    return self;
}

-(id) nextObject
{
    if (counter == 0) return nil;
    id ret = nil;
    ret = [queryBuilder resultsWithOffset:offset andLimit:1];
    offset--;
    counter--;
    
    return [ret objectAtIndex:0];
}

-(id) allObjects
{
    NSMutableArray *array = [NSMutableArray new];
    
    id elem;
    
    while ((elem = [self nextObject]))    {
        [array addObject:elem];
    }
    
    return [[array copy] autorelease];
}

- (void)dealloc {
    [queryBuilder release];
    [super dealloc];
}

@end