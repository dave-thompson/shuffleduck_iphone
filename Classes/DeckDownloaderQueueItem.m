//
//  DeckDownloaderQueueItem.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeckDownloaderQueueItem.h"

@implementation DeckDownloaderQueueItem

-(id)initWithUserVisibleID:(int)aUserVisibleID
{
	[super init];
	
	userVisibleID = aUserVisibleID;
	metadataAlreadyExists = NO;

	return self;
}

-(id)initWithUserVisibleID:(int)aUserVisibleID iPhoneSpecificID:(int)anIphoneSpecificID
{
	[super init];
	
	userVisibleID = aUserVisibleID;
	iPhoneDeckID = anIphoneSpecificID;
	metadataAlreadyExists = YES;

	return self;
}

-(int)userVisibleID
{
	return userVisibleID;
}

-(BOOL)metadataAlreadyExists
{
	return metadataAlreadyExists;
}

-(int)iPhoneDeckID
{
	return iPhoneDeckID;
}

@end
