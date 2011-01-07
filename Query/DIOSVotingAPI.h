//
//  DIOSVotingAPI.h
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 1/1/11.
//  Copyright 2011 Avient-Ivy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIOSConnect.h"

@interface DIOSVotingAPI : DIOSConnect {
    
}

-(id) setVoteForContentType:(NSString *) contentType withContentID:(NSString *) contentID andVote:(NSString *) vote andUID:(NSString *) uid;
-(id) userVotesForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid;
-(id) unsetVoteForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid;
-(id) contentVotesForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid;
-(id) votingResultsForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid;

@end
