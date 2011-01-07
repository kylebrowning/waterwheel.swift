//
//  DIOSVotingAPI.m
//  IPhoneAflicka
//
//  Created by Ugo Enyioha on 1/1/11.
//  Copyright 2011 Avient-Ivy. All rights reserved.
//

#import "DIOSVotingAPI.h"


@implementation DIOSVotingAPI

-(id) setVoteForContentType:(NSString *) contentType withContentID:(NSString *) contentID andVote:(NSString *) vote andUID:(NSString *) uid
{
    [self setMethod:@"votingapi.setVote"];
    [self addParam:contentType forKey:@"content_type"];
    [self addParam:contentID forKey:@"content_id"];
    [self addParam:vote forKey:@"vote"];
    [self addParam:uid forKey:@"uid"];
    [self runMethod];
    return [self connResult];
}

-(id) userVotesForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid
{
    [self setMethod:@"votingapi.getUserVotes"];
    [self addParam:contentType forKey:@"content_type"];
    [self addParam:contentID forKey:@"content_id"];
    [self addParam:uid forKey:@"uid"];
    [self runMethod];
    return [self connResult];
}

-(id) unsetVoteForContentType: (NSString *) contentType
withContentID:(NSString *) contentID andUID: (NSString *) uid
{
    [self setMethod:@"votingapi.unsetVote"];
    [self addParam:contentID forKey:@"content_id"];
    [self addParam:uid forKey:@"uid"];
    return [self connResult];
}

-(id) contentVotesForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid
{
    [self setMethod:@"votingapi.getContentVotes"];
    [self addParam:contentType forKey:@"content_type"];
    [self addParam:contentID forKey:@"content_id"];
    [self addParam:uid forKey:@"uid"];
    [self runMethod];
    return [self connResult];
}

-(id) votingResultsForContentType: (NSString *) contentType withContentID:(NSString *) contentID andUID: (NSString *) uid
{
    [self setMethod:@"votingapi.getVotingResults"];
    [self addParam:contentType forKey:@"content_type"];
    [self addParam:contentID forKey:@"content_id"];
    [self addParam:uid forKey:@"uid"];
    [self runMethod];
    return [self connResult];
}

@end
