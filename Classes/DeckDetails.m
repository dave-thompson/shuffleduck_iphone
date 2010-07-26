//
//  DeckDetails.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DeckDetails.h"

@implementation DeckDetails

@synthesize title, deckID, firstSideID, numCards, numKnownCards, fullyDownloaded, sideViewController;

-(id)initWithID:(int)aDeckID firstSideID:(int)aFirstSideID title:(NSString *)aTitle numCards:(int)theNumCards numKnownCards:(int)theNumKnownCards fullyDownloaded:(BOOL)downloaded
{
	deckID = aDeckID; // the deck ID in the database
	firstSideID = aFirstSideID;
	title = [aTitle retain];
	numCards = theNumCards;
	numKnownCards = theNumKnownCards;
	fullyDownloaded = downloaded;
	return self;
}

-(void)setupSidePreview
{
	// create a view controller for the mini side & set its dimensions
	sideViewController = [[SideViewController alloc] initWithNibName:@"SideView" bundle:nil];
	sideViewController.view.clipsToBounds = YES;
	[sideViewController setCustomSizeByWidth:91]; // height is 56
	sideViewController.view.frame = CGRectMake(0, 0, 91, 56);

	// draw the side
	[sideViewController replaceSideWithSideID:firstSideID];	
}

-(void)dropSideViewController
{
	[sideViewController release];
	sideViewController = nil;
}


- (void)dealloc {
	[title release];
	[sideViewController release];
    [super dealloc];
}


@end
