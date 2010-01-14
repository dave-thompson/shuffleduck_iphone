//
//  DeckDetails.m
//  MindEgg
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DeckDetails.h"

@implementation DeckDetails

@synthesize title, deckID, firstSideID, numCards, numKnownCards;

-(id)initWithID:(int)aDeckID firstSideID:(int)aFirstSideID title:(NSString *)aTitle numCards:(int)theNumCards numKnownCards:(int)theNumKnownCards
{
	deckID = aDeckID; // the deck ID in the database
	firstSideID = aFirstSideID;
	title = [aTitle retain];
	numCards = theNumCards;
	numKnownCards = theNumKnownCards;
	return self;
}

@end
