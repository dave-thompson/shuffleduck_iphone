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

-(id)initWithID:(int)initID firstSideID:(int)initFirstSideID title:(NSString *)initTitle numCards:(int)numberCards numKnownCards:(int)numberKnownCards
{
	deckID = initID;
	firstSideID = initFirstSideID;
	title = [initTitle retain];
	numCards = numberCards;
	numKnownCards = numberKnownCards;
	return self;
}

@end
