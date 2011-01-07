//
//  DIOSViewsQR.m
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 1/3/11.
//  Copyright 2011 Avient-Ivy. All rights reserved.
//

#import "DIOSViewsQBEnumerator.h"

@implementation DIOSViewsQBEnumerator

@synthesize queryBuilder;

-(id) initForList:(DIOSViewsQB *)theViewsQB withOffset:(size_t)off andLimit:(size_t)lim
{
    if ((self = [super init]))   {
        self.queryBuilder = theViewsQB;
        limit = lim;
        offset = off;
        counter = [theViewsQB countResultsWithOffset:off andLimit:lim];
    }
    
    return self;
}

-(id) initForList:(DIOSViewsQB *) theViewsQB
{
    [self initForList:theViewsQB withOffset:0 andLimit:0]; // iterate through all
    return self;
}

-(id) nextObject
{
    id ret = nil;
    
    if (counter == 0) return nil;
    
    ret = [self.queryBuilder resultsWithOffset:offset andLimit:1];
    
    offset++;
    counter--;
    
    return [ret objectAtIndex:0];
}

-(id) allObjects
{
    NSMutableArray *array = [NSMutableArray new];
    
    id object;
    
    while ((object = [self nextObject]))    {
        [array addObject:object];
    }
    
    return [[array copy] autorelease];
}

- (void)dealloc {
    [queryBuilder release];
    [super dealloc];
}

@end
