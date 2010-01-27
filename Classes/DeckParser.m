//
//  DeckParser.m
//  MindEgg
//
//
//  Created by Dave Thompson on 1/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DeckParser.h"
#import "DDXML.h"
#import "ASIHTTPRequest.h"
#import "VariableStore.h"
#import "MyDecksViewController.h"
#import "ProgressViewController.h"
#import "Constants.h"

@implementation DeckParser

@synthesize database;

//NSString *xmlFileName = @"xmlFile.xml";

BOOL inCardsDefinition; // is XML parser currently looking at cards (rather than template)

// variable to store the text within current element
NSString *currentText = @"";

// variables to store current attributes
int userVisibleDeckID;
NSString *text;
int fontID;
CGFloat fontSize;
CGFloat foregroundRed, foregroundGreen, foregroundBlue, foregroundAlpha;
CGFloat backgroundRed, backgroundGreen, backgroundBlue, backgroundAlpha;
int alignmentID;

// variables to store last autogenerated ID
//int deckID;
int cardID;
int sideID;
int componentID;

// variables to store the number of sister nodes thus far encountered
int currentCardPosition;
int currentSidePosition;
int currentComponentPosition;

// debugging variables
NSDate *startTime;

sqlite3_stmt *addStmt;

- (void) getDeckWithUserDeckID:(int)did intoDB:(sqlite3 *)db
{
	// show busy indicator
	[ProgressViewController startShowingProgress];
	
	// store source and destination information
	database = db;
	int userVisibleID = did;
		
	// retrieve deck metadata
	NSURL *url = [NSURL URLWithString:[CONTEXT_URL stringByAppendingString:[NSString stringWithFormat:@"/decks/%d", userVisibleID]]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setUsername:@"dave"];
	[request setPassword:@"wrong"];
	[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", userVisibleID], @"userVisibleID", nil]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(metadataRequestFinished:)];
	[request setDidFailSelector:@selector(metadataRequestFailed:)];
	[request startAsynchronous];
}

- (void) metadataRequestFinished:(ASIHTTPRequest *)request
{
	// instantiate variables
	DDXMLDocument *doc;	
	NSString *responseString = [request responseString];
	doc = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
	if (doc == nil) {[doc release]; return;}
	
	DDXMLElement *rootElement = [doc rootElement];
	if ([XML_ERROR_TAG isEqualToString:[rootElement name]]) // if the server returned an error, abort and tell the user
	{
		// parsing has finished - refresh the UI
		[self updateUIForParsingCompletion];
		
		// tell the user
		NSString *errorDescription = [[[rootElement elementsForName:@"description"] objectAtIndex:0] stringValue];
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:[ERROR_DIALOG_TITLE copy] message:errorDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorAlert show];	
		
	}
	else // the server returned the deck summary information, so process this and then ask for the full deck
	{
		NSString *deckTitle = [[[rootElement elementsForName:@"title"] objectAtIndex:0] stringValue];
		NSString *author = [[[rootElement elementsForName:@"author"] objectAtIndex:0] stringValue];
		int userVisibleID = [[[[[doc rootElement] elementsForName:@"user_visible_id"] objectAtIndex:0] stringValue] integerValue];
		
		// insert a Deck row into the db to represent the incoming deck
		
			// first, increment the positions of all existing Decks to move them down the list
			// write value to database
			sqlite3_stmt *updateStmt = nil;
			if(updateStmt == nil)
			{
				const char *updateSQL = "UPDATE Deck SET position  = position + 1";
				if(sqlite3_prepare_v2(database, updateSQL, -1, &updateStmt, NULL) != SQLITE_OK)
					NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				NSLog(@"Error: updatestmt not nil");
			}
			
			if(SQLITE_DONE != sqlite3_step(updateStmt))
			{NSAssert1(0, @"Error while incrementing DB positions. '%s'", sqlite3_errmsg(database));}
			sqlite3_reset(updateStmt);
			updateStmt = nil;
			
			// now can actually insert the Deck row
			const char *sql = "INSERT INTO Deck(title, position, shuffled, user_visible_id, author) VALUES(?,?,?,?,?)";
			if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			{
				NSLog(@"Error while creating Deck INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			sqlite3_bind_text(addStmt, 1, [deckTitle UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int(addStmt, 2, 1); // position should always be 1 (i.e. at top of list)
			sqlite3_bind_int(addStmt, 3, 0); // deck is initially unshuffled
			sqlite3_bind_int(addStmt, 4, userVisibleID);
			sqlite3_bind_text(addStmt, 5, [author UTF8String], -1, SQLITE_TRANSIENT);	
			if(SQLITE_DONE != sqlite3_step(addStmt))
			{
				NSLog(@"Error running Deck INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				// store the autoincremented primary key to reference from future inserts
				//deckID = sqlite3_last_insert_rowid(database);
			}
			addStmt = nil;
		
		// refresh the decks table to include the new deck
		[[MyDecksViewController getMyDecksViewController] refreshTable];
		
		// ask server to send over full deck details
		NSURL *url = [NSURL URLWithString:[CONTEXT_URL stringByAppendingString:[NSString stringWithFormat:@"/decks/%d/deck_details/1", userVisibleID]]];
		ASIHTTPRequest *fullDeckRequest = [ASIHTTPRequest requestWithURL:url];
		[fullDeckRequest setDelegate:self];
		[fullDeckRequest setDidFinishSelector:@selector(fullDeckRequestFinished:)];
		[fullDeckRequest setDidFailSelector:@selector(fullDeckRequestFailed:)];
		fullDeckRequest.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", userVisibleID], @"userVisibleID",
									nil];
		[fullDeckRequest startAsynchronous];
	}
	
	// clean up
	[doc release];
	
}

- (void)metadataRequestFailed:(ASIHTTPRequest *)request
{
	// What deck does this failure correspond to?
	int userVisibleID = [[request.userInfo valueForKey:@"userVisibleID"] integerValue];

	// tell user that there was a problem and their deck is not being downloaded
	UIAlertView *errorAlert;
	errorAlert =  [[UIAlertView alloc]
					initWithTitle:  [NSString stringWithFormat:@"Couldn't Download Deck with Deck ID %d.", userVisibleID]
					message: [NSString stringWithFormat:@"Please check your network connection and try again."]
					delegate: nil
					cancelButtonTitle: @"OK"
					otherButtonTitles: nil];
				
	[errorAlert show];
	[errorAlert release];
	
	// parsing has finished - refresh the UI
	[self updateUIForParsingCompletion];
}

- (void) fullDeckRequestFinished:(ASIHTTPRequest *)request
{
	// What deck does this response correspond to?
	int userVisibleID = [[request.userInfo valueForKey:@"userVisibleID"] integerValue];
	
	// instantiate variables
	DDXMLDocument *doc;
	
	// get XML response
	NSString *responseString = [request responseString];
	NSLog(responseString);
	
	// create document, ready to parse XML response
	doc = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
	if (doc == nil) // if something went wrong, clean up
	{
		[doc release];
		return;
	}
	
	// populate database based on retrieved xml_string
	NSString *xmlString = [[[[doc rootElement] elementsForName:@"xml_string"] objectAtIndex:0] stringValue];
	[self parseXMLDeck:xmlString withUserID:userVisibleID];
	
	// clean up
	[doc release];
}

- (void) fullDeckRequestFailed:(ASIHTTPRequest *)request
{
	// which deck are we talking about?
		int userVisibleID = [[request.userInfo valueForKey:@"userVisibleID"] integerValue];
	
	// tell user that there was a problem and their deck is not being downloaded
		UIAlertView *errorAlert;
		errorAlert =  [[UIAlertView alloc]
						initWithTitle:  [NSString stringWithFormat:@"Couldn't Download Deck"]
						message: [NSString stringWithFormat:@"Please check your network connection and try again."]
						delegate: nil
						cancelButtonTitle: @"OK"
						otherButtonTitles: nil];
		[errorAlert show];
		[errorAlert release];	

	// clean up
	[self removeDeckWithUserVisibleID:userVisibleID];
	
	// parsing has finished - refresh the UI
	[self updateUIForParsingCompletion];
}


- (void) parseXMLDeck:(NSString *)xmlString withUserID:(int)userVisibleID
{
	startTime = [NSDate date];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[xmlString dataUsingEncoding:NSUnicodeStringEncoding]];
	
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO]; // We don't care about namespaces
    [parser setShouldReportNamespacePrefixes:NO]; //
    [parser setShouldResolveExternalEntities:NO]; // We just want data, no other stuff
	
	// recall userVisibleDeckID so that parser knows where to put cards
	userVisibleDeckID = userVisibleID;
	
	NSLog(@"About to parse.");
    [parser parse]; // Parse the data
	
	
    if ([parser parserError])
	{
		NSLog([parser parserError].localizedDescription);
		
		// remove the offending deck
		[self removeDeckWithUserVisibleID:userVisibleID];
		
		// refresh the UI
		[self updateUIForParsingCompletion];
    }
	
	[self finalizeStatements];
    [parser release];	
}

- (void) parserDidStartDocument:(NSXMLParser *)parserDidStartDocument
{
	NSLog(@"Started parsing XML document");
	inCardsDefinition = NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parserError
{
	NSString *errorString = [NSString stringWithFormat:@"Parser error, error code %i", [parserError code]];
	NSLog(errorString);
	
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading downloaded deck" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	// For all elements....
	currentText = @""; // reset the current Text value ready for any new text node
	
	// for specific elements....
	
	// For cards, create a new cards row in the DB
	if ([elementName isEqualToString:@"Cards"])
	{
		// Log that we're about to receive information on the cards in the deck
		inCardsDefinition = YES;
		currentCardPosition = 0; // will be incremented to 1 for the first card		
	}
	
	// Nodes other than Deck and Cards are only interesting if we're inside a Cards block (otherwise it's template information)
	if (inCardsDefinition)
	{
		if ([elementName isEqualToString:@"Card"])
		{
			int deckID;
			// find out what iPhone deck_id the current userVisibleDeckID corresponds to
				const char *sqlStatement = "SELECT id FROM Deck WHERE user_visible_id =?;";
				sqlite3_stmt *compiledStatement;
				if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
				{
					sqlite3_bind_int(compiledStatement,1,userVisibleDeckID);
					while(sqlite3_step(compiledStatement) == SQLITE_ROW)
					{
						deckID = (int)sqlite3_column_int(compiledStatement, 0);
					}
				}			
				// Release the compiled statement from memory
				sqlite3_finalize(compiledStatement);
			
			
			
			currentCardPosition++;
			currentSidePosition = 0; // will be incremented to 1 before addition of 1st side
			// insert a Card row into the db to represent the incoming card
			const char *sql = "INSERT INTO Card(deck_id, orig_position, position, known) VALUES(?,?,?,?)";
			if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			{
				NSLog(@"Error while creating Card INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			sqlite3_bind_int(addStmt, 1, deckID);
			sqlite3_bind_int(addStmt, 2, currentCardPosition);
			sqlite3_bind_int(addStmt, 3, currentCardPosition);
			sqlite3_bind_int(addStmt, 4, 0);
			
			if(SQLITE_DONE != sqlite3_step(addStmt))
			{
				NSLog(@"Error running Card INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				// store the autoincremented primary key to reference from future inserts
				cardID = sqlite3_last_insert_rowid(database);
			}
			addStmt = nil;
		}
		
		if ([elementName isEqualToString:@"Side"])
		{
			currentSidePosition++;
			currentComponentPosition = 0;
			// insert a Side row into the db to represent the incoming Side
			const char *sql = "INSERT INTO Side(card_id, position) VALUES(?,?)";
			if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			{
				NSLog(@"Error while creating Side INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			sqlite3_bind_int(addStmt, 1, cardID);
			sqlite3_bind_int(addStmt, 2, currentSidePosition);
			
			if(SQLITE_DONE != sqlite3_step(addStmt))
			{
				NSLog(@"Error running Card INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				// store the autoincremented primary key to reference from future inserts
				sideID = sqlite3_last_insert_rowid(database);
			}
			addStmt = nil;
		}
		
		if ([elementName isEqualToString:@"Component"])
		{
			// increment the component position, ready for the new component
			currentComponentPosition++;
			
			// retrieve attribute values from XML
			int x = [[attributeDict valueForKey:@"x"] intValue] ;
			int y = [[attributeDict valueForKey:@"y"] intValue];
			int width = [[attributeDict valueForKey:@"width"] intValue];
			int height = [[attributeDict valueForKey:@"height"] intValue];
			
			// insert a Component row into the db to represent the incoming Component
			const char *sql = "INSERT INTO Component(side_id, display_order,x,y,width,height,type) VALUES(?,?,?,?,?,?,?)";
			if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			{
				NSLog(@"Error while creating Component INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			sqlite3_bind_int(addStmt, 1, sideID);
			sqlite3_bind_int(addStmt, 2, currentComponentPosition);
			sqlite3_bind_int(addStmt, 3, x);
			sqlite3_bind_int(addStmt, 4, y);
			sqlite3_bind_int(addStmt, 5, width);
			sqlite3_bind_int(addStmt, 6, height);
			sqlite3_bind_int(addStmt, 7, 1); // !!!!! TYPE TEMPORARILY HARDCODED TO 1 - TYPE TO LATER BE REMOVED 
			
			if(SQLITE_DONE != sqlite3_step(addStmt))
			{
				NSLog(@"Error running Card INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				// store the autoincremented primary key to reference from future inserts
				componentID = sqlite3_last_insert_rowid(database);
			}
			addStmt = nil;
		}
		
		// For foreground and background color, remember the values given ready for writing to the enclosing TextBox
		if ([elementName isEqualToString:@"foregroundColor"])
		{
			foregroundRed = [[attributeDict valueForKey:@"red"] floatValue];
			foregroundGreen = [[attributeDict valueForKey:@"green"] floatValue];
			foregroundBlue = [[attributeDict valueForKey:@"blue"] floatValue];
		}
		
		if ([elementName isEqualToString:@"backgroundColor"])
		{
			backgroundRed = [[attributeDict valueForKey:@"red"] floatValue];
			backgroundGreen = [[attributeDict valueForKey:@"green"] floatValue];
			backgroundBlue = [[attributeDict valueForKey:@"blue"] floatValue];
		}
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//NSLog(@"Ended this element: %@", elementName);
	
	if ([elementName isEqualToString:@"Cards"])
	{
		inCardsDefinition = NO;
	}
	
	if ([elementName isEqualToString:@"Deck"])
	{
		// parsing has finished
		[self updateUIForParsingCompletion];
	}
	
	// Nodes other than Deck and Cards are only interesting if we're inside a Cards block (otherwise it's template information)
	if (inCardsDefinition)
	{
		// TextBox row must be added to the DB only when we encounter the closing tag: we need the data from its child attributes first
		if ([elementName isEqualToString:@"TextBox"])
		{
			// insert a TextBox row into the db to represent the incoming TextBox
			const char *sql = "INSERT INTO TextBox(component_id, text, font_id, font_size, foreground_red, foreground_green, foreground_blue, foreground_alpha, background_red, background_green, background_blue, background_alpha, alignment_id) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";
			if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			{
				NSLog(@"Error while creating TextBox INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			sqlite3_bind_int(addStmt, 1, componentID);
			sqlite3_bind_text(addStmt, 2, [text UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_double(addStmt, 3, fontID);
			sqlite3_bind_double(addStmt, 4, fontSize);
			sqlite3_bind_double(addStmt, 5, foregroundRed);
			sqlite3_bind_double(addStmt, 6, foregroundGreen);
			sqlite3_bind_double(addStmt, 7, foregroundBlue);
			sqlite3_bind_double(addStmt, 8, foregroundAlpha);
			sqlite3_bind_double(addStmt, 9, backgroundRed);
			sqlite3_bind_double(addStmt, 10, backgroundGreen);
			sqlite3_bind_double(addStmt, 11, backgroundBlue);
			sqlite3_bind_double(addStmt, 12, backgroundAlpha);
			sqlite3_bind_int(addStmt, 13, alignmentID);
			
			if(SQLITE_DONE != sqlite3_step(addStmt))
			{
				NSLog(@"Error running TextBox INSERT statement. '%s'", sqlite3_errmsg(database));
			}
			
			addStmt = nil;
			
			// clean up variables so malformed XML is more likely to be caught
			text = @"";
			fontID = 0;
			fontSize = 0;
			foregroundRed = 0; foregroundGreen = 0; foregroundBlue = 0; foregroundAlpha = 0;
			backgroundRed = 0; backgroundGreen = 0; backgroundBlue = 0; backgroundAlpha = 0;
			alignmentID = 0 ;
		}
		
		if ([elementName isEqualToString:@"text"])
		{
			[text release];
			text = [currentText copy];
		}
		
		if ([elementName isEqualToString:@"font"])
		{
			if ([currentText isEqualToString:@"Arial"])
			{fontID = 1;}
		}
		
		if ([elementName isEqualToString:@"fontSize"])
		{
			fontSize = [currentText floatValue];
		}
		
		if ([elementName isEqualToString:@"alpha"])
		{
			foregroundAlpha = [currentText floatValue];
			backgroundAlpha = foregroundAlpha;
		}
		
		if ([elementName isEqualToString:@"alignment"])
		{
			if([currentText isEqualToString:@"left"])
			{alignmentID = 1;}
			if([currentText isEqualToString:@"center"])
			{alignmentID = 2;}
			if([currentText isEqualToString:@"right"])
			{alignmentID = 3;}
		}
		
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	currentText = [currentText stringByAppendingString:string];	
}

-(void)removeDeckWithUserVisibleID:(int)aUserVisibleID
{
	// remove deck row from DB
	static sqlite3_stmt *deleteStmt = nil;
	NSString *deletionString = [NSString stringWithFormat:@"DELETE FROM Deck WHERE user_visible_id = %d", aUserVisibleID];
	if(deleteStmt == nil)
	{
		const char *sql = [deletionString UTF8String];
		if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
		{
			NSLog(@"Error while creating delete statement while cleaning up partially downloaded deck. '%s'", sqlite3_errmsg(database));
		}
	}
	
	if (SQLITE_DONE != sqlite3_step(deleteStmt))
		NSLog(@"Error while deleting while cleaning up partically downloaded deck. '%s'", sqlite3_errmsg(database));
	
	sqlite3_reset(deleteStmt);
	deleteStmt = nil;
	
	// refresh library
	[[MyDecksViewController getMyDecksViewController] refreshTable];
}

- (void)updateUIForParsingCompletion
{
	// decrement the busy count (for progress indicator management)
	[ProgressViewController stopShowingProgress];
	
	// refresh the library
	[[MyDecksViewController getMyDecksViewController] refreshTable];
}

- (void) finalizeStatements {
	if(addStmt) sqlite3_finalize(addStmt);
}

@end
