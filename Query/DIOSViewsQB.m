//
//  DIOSViewsQB.m
//  iPhoneAflicka
//
//  Created by Ugo Enyioha on 11/26/10.
//  Copyright 2010 Aviant-Ivy. All rights reserved.
//

#import "DIOSViewsQB.h"
#import "MovieDetails.h"
#include "dispatch/dispatch.h"
#include "DIOSViewsQBEnumerator.h"
#include "DIOSViewsQBReverseEnumerator.h"

@implementation DIOSViewsQB

@synthesize viewName, display_id, args, offset, limit, query;

#pragma mark -
#pragma mark Intitializers

// designated initializer
-(id) initWithViewName:(NSString *) vn displayID:(NSString *) dispID args:(NSArray *) argsArray offset:(size_t) off limit:(NSInteger) lim;
{
    if ((self = [super init]))    {
            query = [[DIOSViews alloc] 
                initWithSession:[(IPhoneAflickaAppDelegate *)[[UIApplication sharedApplication] delegate] session]];
            [query initViews];
            
            [query addParam:vn forKey:@"view_name"];
            [query addParam:dispID forKey:@"display_id"];
            
            if (argsArray == nil)    {
                [query addParam:[NSArray arrayWithObjects:nil] forKey:@"args"];
            } else {
                [query addParam:argsArray forKey:@"args"];
            }
        
        // the default offset is zero
        [query addParam:[NSNumber numberWithInt:off] forKey:@"offset"];
        [query addParam:[NSNumber numberWithInt:lim] forKey:@"limit"];
            
        viewName = vn;
        display_id = dispID;
        args = argsArray;
        
        offset = off;
        limit = lim;
    }
    
    return self;
}

-(id) initWithViewName: (NSString *) vn displayID:(NSString *) dispID args:(NSArray *) argsArray
{
    // default is to view all
    return [self initWithViewName:vn displayID:dispID args:args offset:0 limit:0];
}

#pragma mark -
#pragma mark Counters

-(size_t) countResultsWithOffset: (NSInteger) off andLimit: (NSInteger) lim
{
    [query setMethod:@"views.countResults"];
    [query addParam:[NSNumber numberWithInt:off] forKey:@"offset"];
    [query addParam:[NSNumber numberWithInt:lim] forKey:@"limit"];
    [query addParam:[NSNumber numberWithInt:NO] forKey:@"format_output"];
    [query runMethod];
    
    NSNumber *ret = [[self.query connResult] objectForKey:@"#data"];
    [query setMethod:@"views.get"];
    return [ret intValue];
}

#pragma mark -
#pragma mark Compute and count results

-(id) resultsWithOffset: (NSInteger) off andLimit: (NSInteger) lim
{
    // NSLog(@"%d", off);
    [query setMethod:@"views.get"];
    [query addParam:[NSNumber numberWithInt:off] forKey:@"offset"];
    [query addParam:[NSNumber numberWithInt:lim] forKey:@"limit"];
    [query addParam:[NSNumber numberWithInt:NO] forKey:@"format_output"];
    [query runMethod];
    
    id ret = [[self.query connResult] objectForKey:@"#data"];
    
    return ret;
}

-(NSMutableArray *) nextResultSet
{
    [query addParam:[NSNumber numberWithInt:self.offset] forKey:@"offset"];
    [query runMethod];
    
    NSArray *data = [self resultsWithOffset:self.offset andLimit:self.limit];
    
    int num_elems = [data count];
    if (num_elems == 0) return nil;
    
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:num_elems];
    
    [data enumerateObjectsUsingBlock:^(id elem, NSUInteger idx, BOOL *stop) {
        MovieDetails *movieDetails = [[MovieDetails alloc] initWithMovieDetailsData:elem];
        [retArray addObject:movieDetails];
        [movieDetails release];
    }];
    
    offset += num_elems;
    
    return retArray;
}

#pragma mark -
#pragma mark Slow Enumerators (Forward)

-(NSEnumerator *) objectEnumerator
{
    DIOSViewsQBEnumerator *enumerator = 
        [[DIOSViewsQBEnumerator alloc] initForList:self];
    return [enumerator autorelease];
}

-(NSEnumerator *) objectEnumeratorWithOffset: (size_t) off andLimit: (size_t) lim
{
    DIOSViewsQBEnumerator *enumerator = 
        [[DIOSViewsQBEnumerator alloc] initForList:self withOffset:off andLimit:lim];
    return [enumerator autorelease];
}

#pragma mark -
#pragma mark Slow Enumerators (Reverse)

-(NSEnumerator *) reverseObjectEnumerator
{
    DIOSViewsQBReverseEnumerator *reverseEnumerator =
        [[DIOSViewsQBReverseEnumerator alloc] initForList:self];
    return [reverseEnumerator autorelease];
}

-(NSEnumerator *) reverseObjectEnumeratorWithOffset: (size_t) off andLimit: (size_t) lim
{
    DIOSViewsQBReverseEnumerator *reverseEnumerator = 
        [[DIOSViewsQBReverseEnumerator alloc] initForList:self withOffset:off andLimit:lim];
    return reverseEnumerator;
}

#pragma mark -
#pragma mark Fast Enumerators (Forward Only)

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)results count:(NSUInteger)len
{
    int count = 0;
    int off = 0;
    unsigned long mutation = 1;
    id data_ret = nil;
    
    if (state->state == 0)  { // first check
        off = 0;
    } else { // continue from where we left off
        off = state->state;
    }
    
    // extract results from view
    data_ret = [self resultsWithOffset:off andLimit:1];
    
    if ([data_ret respondsToSelector:@selector(count)])  {
        count = [data_ret count];
    } else {
        count = 0;
    }
    
    for (int i = 0; i < count; i++) {
        results[i] = [data_ret objectAtIndex:i];
    }
    
    state->itemsPtr = results;
    state->state = off + count;
    state->mutationsPtr = &mutation;
    
    return count;
}

#pragma mark -
#pragma mark Block Enumerators

- (void)enumerateAllObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (block == nil) 
        [NSException raise:@"NSInvalidArgumentException" format:@"-[DIOSViewsQB enumerateObjectsWithOptions:usingBlock:]: block is nil"];
    
    size_t i = 0;
    BOOL shouldStop = NO;
    
    for (id res in [self objectEnumerator]) {
        block(res, i++, &shouldStop);
        if (shouldStop) break;
    }
}

-(void) enumerateObjectsFromOffset:(size_t) off withLimit:(size_t) lim usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    size_t i = off;
    BOOL shouldStop = NO;
    
    for (id res in [self objectEnumeratorWithOffset:off andLimit:lim])  {
        block(res, i++, &shouldStop);
        if (shouldStop) break;
    }
}

-(void) enumerateObjectsFromOffset:(size_t) off withLimit:(size_t) lim withOptions:(NSEnumerationOptions) opts  usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (block == nil) 
        [NSException raise:@"NSInvalidArgumentException" format:@"-[DIOSViewsQB enumerateObjectsWithOptions:usingBlock:]: block is nil"];
    
    if (opts != NSEnumerationConcurrent)
        [NSException raise:@"NSInvalidArgumentException" format:@"-[DIOSViewsQB enumerateObjectsWithOptions:usingBlock:]: opts is not NSEnumerationConcurrent"];
    
    __block unsigned int i = 0;
    __block BOOL shouldStop = NO;
    __block size_t offset_counter = off;
    
    dispatch_queue_t queryQueue = dispatch_queue_create("com.avient-ivy.queryqueue", NULL); // serial queue
    
    int count = [self countResultsWithOffset:off andLimit:lim];
    
    // This is not purely concurrent. :( NSMutableDictionary is not threadsafe
    // so we gurantee thread safety by scheduling all the async operations on a serial thread
    // we're merely using dispatch apply here to rapidly start off concurrent threads to query drupal
    // TODO: investigate how we can make DIOS support more concurrency
    dispatch_apply(count,
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i){
                       if (!shouldStop)    {
                           dispatch_async(queryQueue, ^{
                               id result = [self resultsWithOffset:offset_counter andLimit:1];
                               block([result objectAtIndex:0], offset_counter, &shouldStop);
                               offset_counter++;
                           });
                       }
                   });
    dispatch_release(queryQueue);
}

// only supports concurrent operations at the moment
- (void)enumerateAllObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsFromOffset:0 withLimit:0 withOptions:opts usingBlock:block];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [query release];
    [viewName release];
    [display_id release];
    [args release];
    [super dealloc];
}

@end
