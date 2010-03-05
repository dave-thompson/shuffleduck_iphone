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
		// deck description
		-(NSString *)getDeckTitle;
		-(NSString *)author;
		-(int)userVisibleID;

		// deck data
		-(int)numCards;
		-(int)numKnownCards;
		-(BOOL)isShuffled;

		// current card / side data
		-(int)getOriginalFirstSideID;
		-(int)getCurrentSideID;
		-(BOOL)isCurrentCardKnown;


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

/* Study mode setters / getters */

	// Setters
		// setting / cleaning up before starting
		-(void)prepareStudySession;
		// changing the user's hand
		-(BOOL)addCardAtEndOfStudySession;
		-(BOOL)addCardToStudySessionAtIndex:(int)index;
		-(BOOL)replaceLastCardInStudySession;
		-(BOOL)replaceCardInStudySessionAtIndex:(int)index;
		// moving within the user's hand
		-(BOOL)moveToNextCardInStudySession;
		-(BOOL)moveToPreviousCardInStudySession;
		-(BOOL)pointToUsersStudySession;

	// Getters
		-(int)numCardsInStudySession;

/* Application State Persistence */

	-(void)rememberCardForStudyType:(StudyType)studyType;
	-(void)setSearchBarText:(NSString *)searchBarText;
	-(NSString *)searchBarText;
	-(int)lastSessionsSideIDForStudyType:(StudyType)studyType;
@end
