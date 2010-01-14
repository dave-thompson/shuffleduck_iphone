//
//  Deck.h
//  MindEgg
//
//  Created by Dave Thompson on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface Deck : NSObject {
	int currentDeckID, currentCardID, currentSideID;
	sqlite3 *database;
}

typedef enum {
	NextCard,      // move to next card in deck
	PreviousCard,  // move to previous card in deck
} ChangeCardDirection;


typedef enum {
	FirstCard, // move to first card in deck
	LastCard,  // move to last card in deck
} CardIndex;


@property (nonatomic, assign) int currentDeckID, currentCardID, currentSideID;
@property (nonatomic, assign) sqlite3 *database;

-(id)initWithDeckID:(int)deckID Database:(sqlite3 *)database includeKnownCards:(BOOL)includeKnown;
-(int)getCurrentSideID;
-(int)getOriginalFirstSideID;
-(int)numCards;
-(int)numKnownCards;

-(BOOL)moveToCardInDirection:(ChangeCardDirection)direction includeKnownCards:(BOOL)includeKnown;
-(BOOL)moveToCardAtPosition:(CardIndex)position includeKnownCards:(BOOL)includeKnown;

-(BOOL)nextSide;

-(BOOL)isCurrentCardKnown;
-(void)setCurrentCardKnown:(BOOL)known;

-(NSString *)getDeckTitle;

-(void)shuffle;
-(void)unshuffle;
-(BOOL)isShuffled;

@end
