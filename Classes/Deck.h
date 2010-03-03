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
}

typedef enum {
	NextCard,      // move to next card in deck
	PreviousCard,  // move to previous card in deck
} ChangeCardDirection;


typedef enum {
	FirstCard, // move to first card in deck
	LastCard,  // move to last card in deck
} CardIndex;

typedef enum {
	View,  // study view being used to view cards
	Learn, // study view being used to memorize cards
	Test,  // study view being used to test a deck
} StudyType;

@property (nonatomic, assign) int currentDeckID, currentCardID, currentSideID;

/* Instantiation */

	-(id)initWithDeckID:(int)deckID includeKnownCards:(BOOL)includeKnown;

/* Navigation */

	// cards
	-(BOOL)moveToCardInDirection:(ChangeCardDirection)direction includeKnownCards:(BOOL)includeKnown;
	-(BOOL)moveToCardInDirection:(ChangeCardDirection)direction withSearchTerm:(NSString *)searchTerm;
	-(BOOL)moveToCardAtPosition:(CardIndex)position includeKnownCards:(BOOL)includeKnown;
	-(BOOL)moveToCardAtPosition:(CardIndex)position withSearchTerm:(NSString *)searchTerm;
	-(void)moveToLastSessionsCardForStudyType:(StudyType)studyType;
	-(BOOL)moveToFirstUnansweredTestQuestion;

	// sides
	-(BOOL)nextSide;

/* Common setters / getters */

	// Getters
	-(int)getOriginalFirstSideID;
	-(int)getCurrentSideID;
	-(int)numCards;
	-(int)numKnownCards;
	-(NSString *)getDeckTitle;
	-(NSString *)author;
	-(int)userVisibleID;
	-(BOOL)isCurrentCardKnown;
	-(BOOL)isShuffled;

	// Setters
	-(void)setCurrentCardKnown:(BOOL)known;
	-(void)shuffle;
	-(void)unshuffle;

/* View Mode setters / getters */

	// Getters
	-(BOOL)currentCardFitsFilter:(NSString *)searchTerm;
	-(int)numCardsWithSearchTerm:(NSString *)searchTerm;

/* Test Mode setters / getters */

	// Setters
	-(void)prepareTest;
	-(void)setTestQuestionCorrect:(BOOL)correct;

	// Getters
	-(BOOL)testIsInProgress;
	-(int)testQuestionsRemaining;
	-(int)cardsCompleted;
	-(int)cardsCorrect;
	-(int)cardsInTestSet;


/* Application State Persistence */

	-(void)rememberCardForStudyType:(StudyType)studyType;
	-(void)setSearchBarText:(NSString *)searchBarText;
	-(NSString *)searchBarText;
	-(int)lastSessionsSideIDForStudyType:(StudyType)studyType;
@end
