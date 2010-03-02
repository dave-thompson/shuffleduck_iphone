//
//  Deck.m
//  MindEgg
//
//  Created by Dave Thompson on 7/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Deck.h"
#import "VariableStore.h"


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
		NSLog([NSString stringWithFormat:@"SQLite request to load find first card / side failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
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
		NSLog([NSString stringWithFormat:@"SQLite request failed: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
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
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	
	if (success == NO) // no rows were returned - i.e. already looking at either the last or first card
	
		{
			if (direction == NextCard)
			{return [self moveToCardAtPosition:FirstCard includeKnownCards:includeKnown];}
			else // direction is ChangeCard Previous
			{return [self moveToCardAtPosition:LastCard includeKnownCards:includeKnown];}
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
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
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

-(void)moveToLastSessionsCardForStudyType:(StudyType)studyType
{
	// find last sessions card
	int lastSessionsCardID, firstSideID;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT Side.card_id, Side.id FROM DeckStatus, Side WHERE DeckStatus.deck_id = %d AND DeckStatus.view_card_id = Side.card_id ORDER BY Side.position ASC LIMIT 1;", currentDeckID];
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
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	
	if (lastSessionsCardID >= 0)
	{
		// if there was a last session, and therefore there was a real card ID, point the deck to that ID
		currentCardID = lastSessionsCardID;
		currentSideID = firstSideID;
	}
	else
	{
		// this is the first time the user has viewed this deck using this StudyType
		// we can safely assume that there is no text in the searchBar
		[self moveToCardAtPosition:FirstCard includeKnownCards:YES];
	}
	
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
			{sql = "UPDATE DeckStatus SET test_card_id = ? WHERE deck_id = ?";}
		else if (studyType == Learn)
			{sql = "UPDATE DeckStatus SET learn_card_id = ? WHERE deck_id = ?";}

		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	sqlite3_bind_int(updateStmt, 1, currentCardID);
	sqlite3_bind_int(updateStmt, 2, currentDeckID);
	
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
		NSLog([NSString stringWithFormat:@"SQLite request to find first card / side failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return nextSideExists;
}

# pragma mark Accessor Methods

-(int)numCards
// returns the number of cards in the current deck
{
	int numCardsInDeck;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Card WHERE Card.deck_id = %d;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			numCardsInDeck = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return numCardsInDeck;
}

-(int)numCardsWithSearchTerm:(NSString *)searchTerm
// returns the number of cards in the current deck
{
	if (searchTerm.length == 0)	return [self numCards];
	
	int numCardsFound;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(DISTINCT Card.id) FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%'", currentDeckID, searchTerm];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			numCardsFound = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return numCardsFound;
}

-(BOOL)currentCardFitsFilter:(NSString *)searchTerm
{
	int countOfCurrentCardInFilteredCards;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(Card.id) FROM Card, Side, Component, TextBox WHERE Card.deck_id = %d AND Card.id = Side.card_id AND Side.id = Component.side_id AND Component.id = TextBox.component_id AND TextBox.text LIKE '%%%@%%' AND Card.id = %d", currentDeckID, searchTerm, currentCardID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			countOfCurrentCardInFilteredCards = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	
	if (countOfCurrentCardInFilteredCards > 0)	return YES;  // count may be greater than 1, as we do not use the DISTINCT keyword
	else										return NO;
	
}

-(int)numKnownCards
// returns the number of known cards in the current deck
{
	int numKnownCardsInDeck;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) FROM Card WHERE Card.deck_id = %d AND Card.known = 1;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			numKnownCardsInDeck = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return numKnownCardsInDeck;
}

-(int)getOriginalFirstSideID
// returns the ID of the first side of the first card (and ignores shuffling)
{
	int firstSideID;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT Side.id AS first_side_id FROM Card, Side WHERE Side.card_id = Card.id AND Card.deck_id = %d AND Card.orig_position = 1 AND Side.position = 1", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			firstSideID = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return firstSideID;
	
}

-(int)getCurrentSideID
{
	return currentSideID;
}

-(BOOL)isCurrentCardKnown
{
	int isCurrentCardKnown;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT known FROM Card WHERE Card.id = %d;", currentCardID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			isCurrentCardKnown = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
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
		
	// write value to database
	sqlite3_stmt *updateStmt = nil;
	if(updateStmt == nil)
	{
		const char *sql = "UPDATE Card SET known = ? WHERE Card.id = ?";
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	
	sqlite3_bind_int(updateStmt, 1, isCurrentCardKnown);
	sqlite3_bind_int(updateStmt, 2, currentCardID);
		
	if(SQLITE_DONE != sqlite3_step(updateStmt))
	{NSAssert1(0, @"Error while updating DB with card known value. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
}

-(NSString *)getDeckTitle
{
	NSString *title;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT title FROM Deck WHERE Deck.id = %d;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return title;
}

-(NSString *)author
{
	NSString *author;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT author FROM Deck WHERE Deck.id = %d;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			author = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return author;
}

-(NSString *)searchBarText
{
	NSString *searchBarText;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT search_text FROM DeckStatus WHERE deck_id = %d;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			searchBarText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return searchBarText;
}

-(void)setSearchBarText:(NSString *)searchBarText
{
	sqlite3_stmt *updateStmt = nil;	
	if(updateStmt == nil)
	{
		const char *sql = "UPDATE DeckStatus SET search_text = ? WHERE deck_id = ?";
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	sqlite3_bind_text(updateStmt, 1, [searchBarText UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(updateStmt, 2, currentDeckID);
	
	if(SQLITE_DONE != sqlite3_step(updateStmt))
	{NSAssert1(0, @"Error while updating DB with new card position. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
}

-(int)userVisibleID
{
	int userVisibleID;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT user_visible_id FROM Deck WHERE Deck.id = %d;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			userVisibleID = sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	return userVisibleID;
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
	sqlite3_stmt *updateStmt = nil;	
	for (int cardNumber = 1; cardNumber <= deckLength; cardNumber++) 	// loop through the cards in the deck and execute an update statement against each one
	{
		// Reposition cards
		if(updateStmt == nil)
		{
			const char *sql = "UPDATE Card SET position = ? WHERE orig_position = ? AND deck_id = ?";
			if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
				NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
		}
		else
		{
			NSLog(@"Error: updatestmt not nil");
		}
		sqlite3_bind_int(updateStmt, 1, [[orderArray objectAtIndex:cardNumber - 1] integerValue]);
		sqlite3_bind_int(updateStmt, 2, cardNumber);
		sqlite3_bind_int(updateStmt, 3, currentDeckID);
				
		if(SQLITE_DONE != sqlite3_step(updateStmt))
		{NSAssert1(0, @"Error while updating DB with new card position. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
		
		sqlite3_reset(updateStmt);
		updateStmt = nil;
	}
	
	// log that deck has been shuffled
	if(updateStmt == nil)
	{
		const char *sql = "UPDATE Deck SET shuffled = 1 WHERE Deck.id = ?";
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	sqlite3_bind_int(updateStmt, 1, currentDeckID);
	
	if(SQLITE_DONE != sqlite3_step(updateStmt))
	{NSAssert1(0, @"Error while updating DB with new card position. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
	
	// Deck is still pointing at old 'first card'. Need to update it to point to new 'first card'.
	// Note that shuffling is done from within the deck details screen, and the deck object is therefore ready for test mode - therefore include known cards
	[self moveToCardAtPosition:FirstCard includeKnownCards:YES];
	
}

-(void)unshuffle
{
	// reset all cards in the deck to their orig_position
	sqlite3_stmt *updateStmt = nil;	
	if(updateStmt == nil)
	{
		const char *sql = "UPDATE Card SET position = orig_position WHERE deck_id = ?";
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	
	sqlite3_bind_int(updateStmt, 1, currentDeckID);
	
	if(SQLITE_DONE != sqlite3_step(updateStmt))
	{NSAssert1(0, @"Error while updating DB with original positions. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
	
	// log that deck is not shuffled
	if(updateStmt == nil)
	{
		const char *sql = "UPDATE Deck SET shuffled = 0 WHERE Deck.id = ?";
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	}
	else
	{
		NSLog(@"Error: updatestmt not nil");
	}
	sqlite3_bind_int(updateStmt, 1, currentDeckID);
	
	if(SQLITE_DONE != sqlite3_step(updateStmt))
	{NSAssert1(0, @"Error while updating DB with new card position. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
	
	// Deck is still pointing at old 'first card'. Need to update it to point to new 'first card'.
	// Note that shuffling is done from within the deck details screen, and the deck object is therefore ready for test mode - therefore include known cards
	[self moveToCardAtPosition:FirstCard includeKnownCards:YES];	
}

-(BOOL)isShuffled
{
	int shuffled;
	NSString *sqlString = [NSString stringWithFormat:@"SELECT shuffled FROM Deck WHERE Deck.id = %d;", currentDeckID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			shuffled = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)]); 
	}
	
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
