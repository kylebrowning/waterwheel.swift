//
//  DIOSViewsQB.h
//  iPhoneAflicka
//
//  Created by Ugo Enyioha on 11/26/10.
//  Copyright 2010 Avient-Ivy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPhoneAflickaAppDelegate.h"
#import "DIOSViews.h"
#import "DIOSConnect.h"

@class IPhoneAflickaAppDelegate;

@interface DIOSViewsQB : NSObject {
    
@private
    NSString *viewName;
    NSString *display_id;
    NSArray *args;
    NSInteger offset;
    NSInteger limit;
    NSInteger curr_offset;
    NSInteger curr_limit;
    DIOSViews *query;
}

#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) DIOSViews *query;
@property (nonatomic, copy) NSString *viewName;
@property (nonatomic, copy) NSString *display_id;
@property (nonatomic, copy) NSArray *args;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger limit;

#pragma mark -
#pragma mark Initializer Declarations

-(id) initWithViewName:(NSString *) vn displayID:(NSString *) dispID args:(NSArray *) argsArray offset:(size_t) off limit:(NSInteger) lim;
-(id) initWithViewName: (NSString *) vn displayID:(NSString *) dispID args:(NSArray *) argsArray;

#pragma mark -
#pragma mark Results Managers

-(id) resultsWithOffset: (NSInteger) off andLimit: (NSInteger) lim;
-(size_t) countResultsWithOffset: (NSInteger) off andLimit: (NSInteger) lim;

#pragma mark -
#pragma mark Slow and Fast Enumerators

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)results count:(NSUInteger)len;
- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)reverseObjectEnumerator;

#pragma mark -
#pragma mark Block Enumerators

- (void) enumerateObjectsFromOffset:(size_t) off withLimit:(size_t) limit withOptions:(NSEnumerationOptions) opts  usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void) enumerateObjectsFromOffset:(size_t) off withLimit:(size_t) limit usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateAllObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
- (void)enumerateAllObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

-(NSMutableArray *) nextResultSet;

@end
