//
//  Deck.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Deck.h"
#import "ShuffleDuckUtilities.h"
#import "VariableStore.h"

#define MAX_NO_CARDS_IN_HAND 10

@implementation Deck

@synthesize currentDeckID, currentCardID, currentSideID;

#pragma mark Iniatialiser

-(id)initWithDeckID:(int)deckID includeKnownCards:(BOOL)includeKnown
// Sets the deck pointer to the first side of the first card.
{
	// populate the currentDeckID
	self.currentDeckID = deckID;
	
	[self moveToCardAtPosition:FirstCard includeKnownCards:includeKnown];
	
	return self;
}

# pragma mark State Updaters

-(BOOL)moveToCardAtPosition:(CardIndex)position includeKnownCards:(BOOL)includeKnown
// Updates the card / side state to point to the first side of either the first or last card.
// Returns true iff there are > 0 cards in the current deck.
{
	BOOL cardsExist = NO;
	// populate the currentCardID, currentSideID
	NSString *sqlString;
	
	if (includeKnown == YES)
	{
		if (position == FirstCard)
			{sqlString = [NSString stringWithFormat:@"SELECT Side.card_id AS CurrentCardID, Side.id AS CurrentSideID FROM Card, Side WHERE Side.card_id = Card.id AND Card.deck_id = %d ORDER BY Card.position ASC, Side.position ASC LIMIT 1;", currentDeckID];}
		else // last card is requested
			{sqlString = [NSString stringWithFormat:@"SELECT Side.card_id AS CurrentCardID, Side.id AS CurrentSideID FROM Card, Side WHERE Side.card_id = Card.id AND Card.deck_id = %d ORDER BY Card.position DESC, Side.position ASC LIMIT 1;", currentDeckID];}
	}
	else // only return unknown cards and also limit to first 10 cards (difference is inline query)
	{
		if (position == FirstCard)
		{sqlString = [NSString stringWithFormat:@"SELECT Side.card_id AS CurrentCardID, Side.id AS CurrentSideID FROM (SELECT * FROM Card WHERE deck_id = %d AND known = 0 ORDER BY Card.position ASC LIMIT 10) AS LimitedCard, Side WHERE Side.card_id = LimitedCard.id AND LimitedCard.deck_id = %d ORDER BY LimitedCard.position ASC, Side.position ASC LIMIT 1;", currentDeckID, currentDeckID];}
		else // last card is requested
		{sqlString = [NSString stringWithFormat:@"SELECT Side.card_id AS CurrentCardID, Side.id AS CurrentSideID FROM (SELECT * FROM Card WHERE deck_id = %d AND known = 0 ORDER BY Card.position ASC LIMIT 10) AS LimitedCard, Side WHERE Side.card_id = LimitedCard.id AND LimitedCard.deck_id = %d ORDER BY LimitedCard.position DESC, Side.position ASC LIMIT 1;", currentDeckID, currentDeckID];}
	}
	
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentCardID = (int)sqlite3_column_int(compiledStatement, 0);
			currentSideID = (int)sqlite3_column_int(compiledStatement, 1);
			cardsExist = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return cardsExist;
}

-(BOOL)moveToCardAtPosition:(CardIndex)position withSearchTerm:(NSString *)searchTerm
// Updates the card / side state to point to the first side of either the first or last card that matches the given search term
// Returns true iff there are > 0 cards in the current deck.
{
	// if no search term was supplied, move to the card at the requested position
	if (searchTerm.length == 0)
	{
		return [self moveToCardAtPosition:position includeKnownCards:YES];
	}
	
	// otherwise, use the search term...
	BOOL cardsExist = NO;
	NSString *sqlString;
	
	if (position == FirstCard)
		{sqlString = [NSString stringWithFormat:@"SELECT Side.card_id AS CurrentCardID, Side.id AS CurrentSideID FROM (SELECT DISTINCT Card.id, Card.position FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%') AS LimitedCard, Side WHERE Side.card_id = LimitedCard.id ORDER BY LimitedCard.position ASC, Side.position ASC LIMIT 1;", currentDeckID, searchTerm];}
	else // last card is requested
		{sqlString = [NSString stringWithFormat:@"SELECT Side.card_id AS CurrentCardID, Side.id AS CurrentSideID FROM (SELECT DISTINCT Card.id, Card.position FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%') AS LimitedCard, Side WHERE Side.card_id = LimitedCard.id ORDER BY LimitedCard.position DESC, Side.position ASC LIMIT 1;", currentDeckID, searchTerm];}
	
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentCardID = (int)sqlite3_column_int(compiledStatement, 0);
			currentSideID = (int)sqlite3_column_int(compiledStatement, 1);
			cardsExist = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return cardsExist;
}

-(BOOL)moveToCardInDirection:(ChangeCardDirection)direction includeKnownCards:(BOOL)includeKnown
// Updates state to point to the first side of the requested card. Decks are treated as continuous - i.e. the first card is after the last card; the last card is before the first card.
// Returns NO iff there are < 2 cards in the current deck (after filtering out known cards if requested).
{	
	if ([self numCards] < 2)
	{return NO;}
	
	// Retrieve the next or previous card & side ids
	BOOL success = NO;
	NSString *sqlString;

	if (includeKnown == YES)
	{
		if (direction == NextCard)
			{sqlString = [NSString stringWithFormat:@"SELECT next_card.id AS next_card_id, next_side.id AS next_side_id FROM Card current_card, Card next_card, Side next_side WHERE current_card.id = %d AND next_card.deck_id = %d AND next_card.position >  current_card.position AND next_card.id = next_side.card_id ORDER BY next_card.position ASC, next_side.position ASC LIMIT 1;", currentCardID, currentDeckID];}
		else // direction is PreviousCard
		{sqlString = [NSString stringWithFormat:@"SELECT previous_card.id AS previous_card_id, previous_side.id AS previous_side_id FROM Card current_card, Card previous_card, Side previous_side WHERE current_card.id = %d AND previous_card.deck_id = %d AND previous_card.position <  current_card.position AND previous_card.id = previous_side.card_id ORDER BY previous_card.position DESC, previous_side.position ASC LIMIT 1;", currentCardID, currentDeckID];}
	}
	else // only return unknown cards and also limit to first 10 cards (difference is inline query)
	{
		if (direction == NextCard)
		{sqlString = [NSString stringWithFormat:@"SELECT next_card.id AS next_card_id, next_side.id AS next_side_id FROM Card current_card,  (SELECT * FROM Card WHERE deck_id = %d AND known = 0 ORDER BY Card.position ASC LIMIT 10) AS next_card, Side next_side WHERE current_card.id = %d AND next_card.deck_id = %d AND next_card.position >  current_card.position AND next_card.id = next_side.card_id ORDER BY next_card.position ASC, next_side.position ASC LIMIT 1;", currentDeckID, currentCardID, currentDeckID];}
		else // direction is PreviousCard
		{sqlString = [NSString stringWithFormat:@"SELECT previous_card.id AS previous_card_id, previous_side.id AS previous_side_id FROM Card current_card, (SELECT * FROM Card WHERE deck_id = %d AND known = 0 ORDER BY Card.position ASC LIMIT 10) AS previous_card, Side previous_side WHERE current_card.id = %d AND previous_card.deck_id = %d AND previous_card.position <  current_card.position AND previous_card.id = previous_side.card_id ORDER BY previous_card.position DESC, previous_side.position ASC LIMIT 1;", currentDeckID, currentCardID, currentDeckID];}
		
	}
	
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentCardID = (int)sqlite3_column_int(compiledStatement, 0);
			currentSideID = (int)sqlite3_column_int(compiledStatement, 1);
			success = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	
	if (success == NO) // no rows were returned - i.e. already looking at either the last or first card
		{
			if (direction == NextCard)
				return [self moveToCardAtPosition:FirstCard includeKnownCards:includeKnown];
			else // direction is ChangeCard Previous
				return [self moveToCardAtPosition:LastCard includeKnownCards:includeKnown];
		}	
	else
		{return success;}
}

-(BOOL)moveToCardInDirection:(ChangeCardDirection)direction withSearchTerm:(NSString *)searchTerm
// Updates state to point to the first side of the requested card. Decks are treated as continuous - i.e. the first card is after the last card; the last card is before the first card.
// Returns NO iff there are < 2 cards that match the given search term.
{
	// if no search term was supplied, move to the card in requested direction
	if (searchTerm.length == 0)
	{
		return [self moveToCardInDirection:direction includeKnownCards:YES];
	}	
	
	BOOL success = NO;
	NSString *sqlString;
	
	if (direction == NextCard)
		{sqlString = [NSString stringWithFormat:@"SELECT next_card.id AS next_card_id, next_side.id AS next_side_id FROM Card current_card, (SELECT DISTINCT Card.id, Card.position FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%') AS next_card, Side next_side WHERE current_card.id = %d AND next_card.position >  current_card.position AND next_card.id = next_side.card_id ORDER BY next_card.position ASC, next_side.position ASC LIMIT 1;", currentDeckID, searchTerm, currentCardID, currentDeckID];}
	else // direction is PreviousCard
		{sqlString = [NSString stringWithFormat:@"SELECT previous_card.id AS previous_card_id, previous_side.id AS previous_side_id FROM Card current_card, (SELECT DISTINCT Card.id, Card.position FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%') AS previous_card, Side previous_side WHERE current_card.id = %d AND previous_card.position <  current_card.position AND previous_card.id = previous_side.card_id ORDER BY previous_card.position DESC, previous_side.position ASC LIMIT 1;", currentDeckID, searchTerm, currentCardID, currentDeckID];}
	
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentCardID = (int)sqlite3_column_int(compiledStatement, 0);
			currentSideID = (int)sqlite3_column_int(compiledStatement, 1);
			success = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	
	if (success == NO) // no rows were returned - i.e. already looking at either the last or first card
		
	{
		if (direction == NextCard)
			{return [self moveToCardAtPosition:FirstCard withSearchTerm:searchTerm];}
		else // direction is ChangeCard Previous
			{return [self moveToCardAtPosition:LastCard withSearchTerm:searchTerm];}
	}	
	else
	{return success;}
}

-(BOOL)moveToFirstUnansweredTestQuestion
// moves the card & side pointers to the first unanswered test question
// returns false if there are no remaining unanswered questions
{
	// Retrieve the next or previous card & side ids
	BOOL success = NO;
	NSString *sqlString;
	
	sqlString = [NSString stringWithFormat:@"SELECT TestStatus.card_id, Side.id FROM TestStatus, Side WHERE TestStatus.deck_id = %d AND TestStatus.completed = 0 AND TestStatus.card_id = Side.card_id ORDER BY TestStatus.question_number ASC, Side.position ASC LIMIT 1;", currentDeckID];
		
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentCardID = (int)sqlite3_column_int(compiledStatement, 0);
			currentSideID = (int)sqlite3_column_int(compiledStatement, 1);
			success = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return success;
}

-(int)lastSessionsSideIDForStudyType:(StudyType)studyType
{
	NSString *sqlString;

	if (studyType == Test)
		sqlString = [NSString stringWithFormat:@"SELECT test_side_id FROM DeckStatus WHERE deck_id = %d;", currentDeckID];
	else if (studyType == Learn)
		sqlString = [NSString stringWithFormat:@"SELECT learn_side_id FROM DeckStatus WHERE deck_id = %d;", currentDeckID];		

	return [ShuffleDuckUtilities getIntUsingSQL:sqlString];
}

-(void)moveToLastSessionsCardForStudyType:(StudyType)studyType
{
	if (studyType == Test)
	{
		// just move to the first unanswered test question
		[self moveToFirstUnansweredTestQuestion];
	}
	else if (studyType == Learn)
	{
		// just move to the first card in the user's hand
		[self pointToUsersStudySession];
	}
	else if (studyType == View)
	{
		// find last sessions card
		NSString *sqlString;
		int lastSessionsCardID = -1;
		int firstSideID = -1;
		
		sqlString = [NSString stringWithFormat:@"SELECT Side.card_id, Side.id FROM DeckStatus, Side WHERE DeckStatus.deck_id = %d AND DeckStatus.view_card_id = Side.card_id ORDER BY Side.position ASC LIMIT 1;", currentDeckID];
		const char *sqlStatement = [sqlString UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{
				lastSessionsCardID = (int)sqlite3_column_int(compiledStatement, 0);
				firstSideID = (int)sqlite3_column_int(compiledStatement, 1);
			}
		}
		else
		{
			NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
		}
		
		if (lastSessionsCardID >= 0)
		{
			// if there was a last session, and therefore there was a real card ID, point the deck to that ID
			currentCardID = lastSessionsCardID;
			currentSideID = firstSideID;			
		}
		else // this is the first time the user has viewed this deck using this StudyType
		{
			[self moveToCardAtPosition:FirstCard includeKnownCards:YES];
			// (we can safely assume that there is no text in the searchBar)
		}
	}
}

-(BOOL)testIsInProgress
// checks to see if there is a test already in progress for the current deck
{	
	if ([self testQuestionsRemaining] > 0)	return YES;
	else									return NO;
}

-(void)prepareTest
// prepares a new test for the current deck
{
	// Clear any existing test
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM TestStatus WHERE deck_id = %d", currentDeckID]];
	
	// Set up new test
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"INSERT INTO TestStatus (deck_id, card_id, question_number, completed, correct) SELECT deck_id, id, position, 0, 0 FROM Card WHERE Card.deck_id = %d ORDER BY Card.position", currentDeckID]];
}

-(void)prepareStudySession
{	
	// remove any cards from the hand that are already known (a DB trigger updates the positions of the remaining cards)
	NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE card_id IN (SELECT id FROM Card WHERE deck_id = %d AND known = 1)", currentDeckID, currentDeckID];
	[ShuffleDuckUtilities runSQLUpdate:sqlString];

	// if there are more cards in the hand than the MAX_NO_CARDS_IN_HAND, truncate the hand
	int numCardsInHand = [self numCardsInStudySession];
	int numCardsToRemove = numCardsInHand - MAX_NO_CARDS_IN_HAND;
	if (numCardsToRemove > 0)
		[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE card_id IN (SELECT card_id FROM StudyStatus WHERE deck_id = %d ORDER BY position DESC LIMIT %d)", currentDeckID, numCardsToRemove]];
		
	// if there are less cards in the hand than the MAX_NO_CARDS_IN_HAND, add cards to end of hand until there are enough or until there are no cards left
	int numCardsToAdd = MAX_NO_CARDS_IN_HAND - numCardsInHand;
	BOOL cardsRemain = YES;
	for (int i = 0; i < numCardsToAdd && cardsRemain; i ++)
	{
		sqlite3_exec([VariableStore sharedInstance].database, "BEGIN", 0, 0, 0); // wrapping in transaction provides huge performance boost
		cardsRemain = [self addCardAtEndOfStudySession];
		sqlite3_exec([VariableStore sharedInstance].database, "COMMIT", 0, 0, 0);
	}
}

-(int)numCardsInStudySession
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT(*) FROM StudyStatus WHERE deck_id = %d", currentDeckID]];
}

-(BOOL)doesCurrentCardContainSideID:(int)aSideID
{
	
	int numInstancesOfSideInCurrentCard = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT(*) FROM Side WHERE card_id = %d AND id = %d", currentCardID, aSideID]];
	if (numInstancesOfSideInCurrentCard > 0)
		return YES;
	else
		return NO;
}

-(BOOL)addCardAtEndOfStudySession
{
	return [self addCardToStudySessionAtIndex:[self numCardsInStudySession]];
}

-(BOOL)addCardToStudySessionAtIndex:(int)index
// adds an unknown card to the given index of a user's hand during Study mode
// if adding to anywhere other than the end, it is the caller's responsibility to free up the requested index in the DB before calling this method
// returns YES iff there was an unknown card to add, or NO if no card was added
{
	// find the first card in the deck that is not already in the hand
	int cardIDToAdd = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT id FROM Card WHERE deck_id = %d AND known = 0 AND id NOT IN ( SELECT card_id FROM StudyStatus WHERE deck_id = %d ) ORDER BY position LIMIT 1;", currentDeckID, currentDeckID]];
	if (cardIDToAdd != -1) // if there is an unknown card left to add
	{
		[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"INSERT INTO StudyStatus (deck_id, card_id, position) VALUES (%d, %d, %d)", currentDeckID, cardIDToAdd, index]];
		return YES;
	}
	else
	{
		return NO;
	}
}

-(BOOL)replaceLastCardInStudySession
// replaces the card at the bottom of the user's hand with an unknown card
// returns YES iff there was an unknown card to add, or NO if the first card was removed but no card was added in its place
{
	// remove the bottom card
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE card_id IN (SELECT card_id FROM StudyStatus WHERE deck_id = %d ORDER BY position DESC LIMIT 1)", currentDeckID]];
	// add the new card in its place
	return [self addCardAtEndOfStudySession];
}

-(BOOL)replaceCardInStudySessionAtIndex:(int)index
// replaces the card at the requested index of a user's hand with an unknown card
// returns YES iff there was an unknown card to add, or NO if the first card was removed but no card was added in its place
{
	// remove the card at index
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE deck_id = %d AND POSITION = %d", currentDeckID, index]];
	if ([self numCardsInStudySession] < ([self numCards] - [self numKnownCards]))
	{
		// make space at the requested index
		[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE StudyStatus SET position = position + 1 WHERE deck_id = %d AND position > %d", currentDeckID, index - 1]];
		// add the new card at index
		return [self addCardToStudySessionAtIndex:index];
	}
	else
	{
		return NO;
	}
}

-(BOOL)moveToNextCardInStudySession
{
	if ([self numCardsInStudySession] > 1)
	{
		// move the current card to the back
			// remove it from the front
			int movingCardID = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT card_id FROM StudyStatus WHERE deck_id = %d AND position = 0", currentDeckID]];
			[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE card_id = %d", movingCardID]];
			// add it to the back
			int numCardsInHand = [self numCardsInStudySession]; // this is actually one less than is usually in the hand, as we have deleted but not yet re-added
			[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"INSERT INTO StudyStatus (deck_id, card_id, position) VALUES (%d, %d, %d)", currentDeckID, movingCardID, numCardsInHand]];
		// move card & side pointers to show the front card
		[self pointToUsersStudySession];
		return YES;
	}
	else
	{
		return NO;
	}
}

-(BOOL)moveToPreviousCardInStudySession
{
	if ([self numCardsInStudySession] > 1)
	{
		// move the back card to the front
			// increment all positions
			[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE StudyStatus SET position = position + 1 WHERE deck_id = %d", currentDeckID]];
			// remove the back card
			int numCardsInHand = [self numCardsInStudySession];
			int movingCardID = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT card_id FROM StudyStatus WHERE deck_id = %d AND position = %d", currentDeckID, numCardsInHand]];
			[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE card_id = %d", movingCardID]];
			// add it to the front
			[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"INSERT INTO StudyStatus (deck_id, card_id, position) VALUES (%d, %d, %d)", currentDeckID, movingCardID, 0]];
		// move card & side pointers to show the front card
		[self pointToUsersStudySession];
		return YES;
	}
	else
	{
		return NO;
	}
}

-(BOOL)pointToUsersStudySession
// moves the card & side pointers to the top card in the user's hand
// returns false if there are no cards in the user's hand
{
	// Retrieve the next or previous card & side ids
	BOOL success = NO;
	NSString *sqlString;
	
	sqlString = [NSString stringWithFormat:@"SELECT StudyStatus.card_id, Side.id FROM StudyStatus, Side WHERE StudyStatus.deck_id = %d AND StudyStatus.card_id = Side.card_id ORDER BY StudyStatus.position ASC, Side.position ASC LIMIT 1;", currentDeckID];
	
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentCardID = (int)sqlite3_column_int(compiledStatement, 0);
			currentSideID = (int)sqlite3_column_int(compiledStatement, 1);
			success = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return success;
}		

-(void)rememberCardForStudyType:(StudyType)studyType
// Serializes the currently viewed card ID so it may be reloaded when the user comes back to the given StudyType
{
	sqlite3_stmt *updateStmt = nil;	
	if(updateStmt == nil)
	{
		const char *sql;
		if (studyType == View)
			{sql = "UPDATE DeckStatus SET view_card_id = ? WHERE deck_id = ?";}
		else if (studyType == Test)
			{sql = "UPDATE DeckStatus SET test_card_id = ?, test_side_id = ? WHERE deck_id = ?";}
		else if (studyType == Learn)
			{sql = "UPDATE DeckStatus SET learn_card_id = ?, learn_side_id = ? WHERE deck_id = ?";}

		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	sqlite3_bind_int(updateStmt, 1, currentCardID);
	if (studyType == View)
		sqlite3_bind_int(updateStmt, 2, currentDeckID);
	else // studyType == Test or Learn
	{
		sqlite3_bind_int(updateStmt, 2, currentSideID);
		sqlite3_bind_int(updateStmt, 3, currentDeckID);		
	}
	if(SQLITE_DONE != sqlite3_step(updateStmt))
	{NSAssert1(0, @"Error while updating DB with new card position. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
}

-(BOOL)nextSide
// Updates state to point to the next side of the current card.
// Returns NO iff there are no more sides to display for the current card (i.e. last side already displayed).
{
	BOOL nextSideExists = NO;
	// Query database for the next side ID
	NSString *sqlString = [NSString stringWithFormat:@"SELECT next_side.id FROM Side next_side, Side current_side WHERE current_side.id = %d AND next_side.card_id = current_side.card_id AND next_side.position > current_side.position ORDER BY next_side.position ASC LIMIT 1;", currentSideID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			currentSideID = (int)sqlite3_column_int(compiledStatement, 0);
			nextSideExists = YES;
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return nextSideExists;
}

# pragma mark Accessor Methods

-(int)numCards
// returns the number of cards in the current deck
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT(*) FROM Card WHERE Card.deck_id = %d;", currentDeckID]];
}

-(int)cardsCompleted;
// returns the number of questions answered in any current test run
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT (*) FROM TestStatus WHERE deck_id = %d AND completed = 1;", currentDeckID]];
}

-(int)cardsCorrect;
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT (*) FROM TestStatus WHERE deck_id = %d AND correct = 1;", currentDeckID]];
}

-(int)cardsInTestSet;
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT (*) FROM TestStatus WHERE deck_id = %d;", currentDeckID]];
}

-(int)testQuestionsRemaining
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT (*) FROM TestStatus WHERE deck_id = %d AND completed = 0;", currentDeckID]];
}

-(int)numCardsWithSearchTerm:(NSString *)searchTerm
{
	if (searchTerm.length == 0)
	{
		return [self numCards];
	}
	else
	{
		return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT(DISTINCT Card.id) FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%'", currentDeckID, searchTerm]];
	}
}

-(BOOL)currentCardFitsFilter:(NSString *)searchTerm
{
	int countOfCurrentCardInFilteredCards = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT(Card.id) FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%' AND Card.id = %d", currentDeckID, searchTerm, currentCardID]];
	
	if (countOfCurrentCardInFilteredCards > 0)	return YES;  // count may be greater than 1, as we do not use the DISTINCT keyword
	else										return NO;	
}

-(int)numKnownCards
// returns the number of known cards in the current deck
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT COUNT(*) FROM Card WHERE Card.deck_id = %d AND Card.known = 1;", currentDeckID]];	
}

-(int)getOriginalFirstSideID
// returns the ID of the first side of the first card (and ignores shuffling)
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT Side.id AS first_side_id FROM Card, Side WHERE Side.card_id = Card.id AND Card.deck_id = %d AND Card.orig_position = 1 AND Side.position = 1", currentDeckID]];	
}

-(int)getCurrentSideID
{
	return currentSideID;
}

-(BOOL)isCurrentCardKnown
{
	int isCurrentCardKnown = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT known FROM Card WHERE Card.id = %d;", currentCardID]];

	if (isCurrentCardKnown == 0)
		{return NO;}
	else
		{return YES;}
}

-(void)setCurrentCardKnown:(BOOL)known
{
	// derive sqlite3 friendly boolean
	int isCurrentCardKnown;
	if (known == YES)
		{isCurrentCardKnown = 1;}
	else
		{isCurrentCardKnown = 0;}
		
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE Card SET known = %d WHERE Card.id = %d", isCurrentCardKnown, currentCardID]];
}

-(void)setTestQuestionCorrect:(BOOL)correct
{
	// update test data
		// derive sqlite3 friendly boolean
		int isCorrect;
		if (correct == YES)
			isCorrect = 1;
		else
			isCorrect = 0;
		// write value to database
		[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE TestStatus SET completed = 1, correct = %d WHERE deck_id = %d AND card_id = %d", isCorrect, currentDeckID, currentCardID]];
	
	// also update known flag
	[self setCurrentCardKnown:correct];
}

-(NSString *)getDeckTitle
{
	return [ShuffleDuckUtilities getStringUsingSQL:[NSString stringWithFormat:@"SELECT title FROM Deck WHERE Deck.id = %d;", currentDeckID]];	
}

-(NSString *)author
{
	return [ShuffleDuckUtilities getStringUsingSQL:[NSString stringWithFormat:@"SELECT author FROM Deck WHERE Deck.id = %d;", currentDeckID]];
}

-(NSString *)searchBarText
{
	return [ShuffleDuckUtilities getStringUsingSQL:[NSString stringWithFormat:@"SELECT search_text FROM DeckStatus WHERE deck_id = %d;", currentDeckID]];
}

-(void)setSearchBarText:(NSString *)searchBarText
{
	NSString *sqlString = [NSString stringWithFormat:@"UPDATE DeckStatus SET search_text = %d WHERE deck_id = %d", searchBarText, currentDeckID];
	[ShuffleDuckUtilities runSQLUpdate:sqlString];	
}

-(int)userVisibleID
{
	return [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT user_visible_id FROM Deck WHERE Deck.id = %d;", currentDeckID]];
}

-(void)shuffle
{
	int deckLength = self.numCards;

	// create an array of sequential integers from 1...deck length
	NSMutableArray *orderArray = [NSMutableArray arrayWithCapacity:deckLength];
	for (int cardNumber = 1; cardNumber <= deckLength; cardNumber++)
	{
		NSNumber *arrayCompatibleCardNumber = [NSNumber numberWithInt:cardNumber];
		[orderArray addObject:arrayCompatibleCardNumber];
	}
	
	// randomise the order of integers in the array, using Durstenfeld's algorithm
	int cardsRemainingToShuffle = deckLength;
	while (cardsRemainingToShuffle > 1)
	{
		int rand = arc4random() % cardsRemainingToShuffle;
		int cardIndex = cardsRemainingToShuffle - 1;
		[orderArray exchangeObjectAtIndex:cardIndex withObjectAtIndex:rand];
		cardsRemainingToShuffle--;
	}
	
	// update the database to position each card according to the randomly ordered array
	for (int cardNumber = 1; cardNumber <= deckLength; cardNumber++) 	// loop through the cards in the deck and execute an update statement against each one
	{
		[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE Card SET position = %d WHERE orig_position = %d AND deck_id = %d", [[orderArray objectAtIndex:cardNumber - 1] integerValue],cardNumber,currentDeckID]];
	}
	
	// log that deck has been shuffled
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE Deck SET shuffled = 1 WHERE Deck.id = %d", currentDeckID]];
		
	// ditch the current learning session (later a new one will be created with the shuffled deck)
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE deck_id = %d", currentDeckID]];
	
	// also wipe the user's Study position, so that they are put back into the deck at a random location
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE DeckStatus SET learn_card_id = -1, learn_side_id = -1 WHERE deck_id = %d", currentDeckID]];
}

-(void)unshuffle
{
	// reset all cards in the deck to their orig_position
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE Card SET position = orig_position WHERE deck_id = %d", currentDeckID]];	
	
	// log that deck is not shuffled
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE Deck SET shuffled = 0 WHERE Deck.id = %d",currentDeckID]];

	// ditch the current learning session (later a new one will be created with the shuffled deck)
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"DELETE FROM StudyStatus WHERE deck_id = %d", currentDeckID]];
	
	// also wipe the user's Study position, so that they are put back into the deck at a random location
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE DeckStatus SET learn_card_id = -1, learn_side_id = -1 WHERE deck_id = %d", currentDeckID]];	
}

-(BOOL)isShuffled
{
	int shuffled = [ShuffleDuckUtilities getIntUsingSQL:[NSString stringWithFormat:@"SELECT shuffled FROM Deck WHERE Deck.id = %d;", currentDeckID]];
	
	BOOL returnValue;
	if (shuffled == 1)
	{
		returnValue = YES;
	}
	else
	{
		returnValue = NO;
	}
	return returnValue;
}

@end
