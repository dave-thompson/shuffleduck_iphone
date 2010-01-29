//
//  MyDecksViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MyDecksViewController.h"
#import "DownloadViewController.h"
#import "DeckDetails.h"
#import "LibraryCell.h"
#import "ReviseViewController.h"
#import "SideViewController.h"
#import "DDXML.h"
#import "DeckParser.h"
#import "VariableStore.h"
#import "ProgressViewController.h"
#import "Constants.h"
#import "ASIAuthenticationDialog.h"
#import "MindEggUtilities.h"

@implementation MyDecksViewController

@synthesize database;

static sqlite3_stmt *deleteStmt = nil;

static MyDecksViewController *myDecksViewController;

/*
// manage the shared instance of this singleton View Controller
+ (MyDecksViewController *)sharedInstance
{
	static MyDecksViewController *sharedMyDecksViewController;
    if (sharedMyDecksViewController == nil)
	{
        sharedMyDecksViewController = [[[self class] alloc] init];
    }
    return sharedMyDecksViewController;
}
*/

+ (id)getMyDecksViewController
{
	return myDecksViewController;
} 

#pragma mark View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//setup custom back button
	UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"]
																		style:UIBarButtonItemStyleDone
																	   target:nil
																	   action:nil];
	self.navigationItem.backBarButtonItem = backArrowButton;
	[backArrowButton release];
	
	// setup feedback button
	UIBarButtonItem *downloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(pushFeedbackScreen:)]; 
	self.navigationItem.rightBarButtonItem = downloadButton;
	[downloadButton release];
	
	// Sync / Download Buttons
	/*
		// setup download button
		UIBarButtonItem *downloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushDownloadScreen:)]; 
		self.navigationItem.rightBarButtonItem = downloadButton;
		[downloadButton release];
		
		// setup sync button
		UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(syncDecksWithServer:)]; 
		self.navigationItem.leftBarButtonItem = syncButton;
		[syncButton release];
	*/
	
	// create table footer
	tableFooterViewController = [[TableFooterViewController alloc] initWithNibName:@"TableFooterView" bundle:nil];
	
	 // SEE http[colon]//adeem.me/blog/2009/05/29/iphone-sdk-tutorial-add-delete-reorder-uitableview-row/
	 // POSSIBLE USE OF EDIT FUNCTIONALITY TO REPLACE DOWNLOAD BUTTON, WITH GREEN ADD ROW OPTION....
	// setup edit button
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTable:)];
	[self.navigationItem setLeftBarButtonItem:editButton];
	[editButton release];
	
	myDecksViewController = self;
}

- (void)viewWillAppear:(BOOL)animated
{	
	// refresh table
	[self refreshTable];
	
	// make status bar blue
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault]; //UIStatusBarStyleBlackOpaque];
	
	// make navigation bar blue
	UINavigationController *navController = [self navigationController];
	navController.navigationBar.barStyle = UIBarStyleDefault; //UIBarStyleBlackOpaque;
	
	[super viewWillAppear:animated];
}

-(void)refreshTable
{
	// update library details
	[self retrieveLocalLibraryDetails];

	// update table from local library details
	[libraryTableView reloadData];
	[self updateTableSettingsBasedOnNumberOfDecks];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int numberOfRows = [self numDecks];
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *libraryCellIdentifier = @"LibraryCell";
	
	LibraryCell *cell = (LibraryCell *)[tableView dequeueReusableCellWithIdentifier:libraryCellIdentifier];
	if (cell == nil)
	{
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LibraryCell" owner:self options:nil];
		#ifdef __IPHONE_2_1
			cell = (LibraryCell *)[nib objectAtIndex:0];
		#else
			cell = (LibraryCell *)[nib objectAtIndex:1];
		#endif
	}
	
	NSUInteger row = [indexPath row];
	NSLog([NSString stringWithFormat:@"%d", row]);
	DeckDetails *currentCellDeck = (DeckDetails *)[localLibraryDetails objectAtIndex:(row)];
	
	cell.deckTitle.text = currentCellDeck.title;
	cell.known.text = [NSString stringWithFormat:@"%d", currentCellDeck.numKnownCards];
	cell.unknown.text = [NSString stringWithFormat:@"%d", currentCellDeck.numCards - currentCellDeck.numKnownCards];	
	SideViewController *miniSideViewController = [[SideViewController alloc] initWithNibName:@"SideView" bundle:nil];
	miniSideViewController.view.clipsToBounds = YES;
	[miniSideViewController setCustomSizeByWidth:104]; // height is 64; multiplier is 0.4
	[miniSideViewController replaceSideWithSideID:currentCellDeck.firstSideID FromDB:database];
	miniSideViewController.view.frame = CGRectMake(0, 0, 104, 64);
	[cell.miniCardView addSubview:miniSideViewController.view];
	cell.miniCardViewController = miniSideViewController;
	[miniSideViewController release];
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// return same height as that of LibraryCell...
	// .. but 1 greater than the height of LibraryCell's view
	return 65;
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// find the DB deck id for the selected row
	int selectedDeckIndex = [indexPath indexAtPosition:([indexPath length]-1)];
	DeckDetails* selectedDeckDetails = [localLibraryDetails objectAtIndex:selectedDeckIndex];
	int DBDeckID = selectedDeckDetails.deckID;
	
	// instantiate a deck object for this deck ID
	Deck *deck = [[Deck alloc] initWithDeckID:DBDeckID Database:database includeKnownCards:YES];
	
	// Push a deck detail view controller (referencing the new deck object) onto the navigation stack
	if (deckDetailViewController == nil)
	{
		deckDetailViewController = [[DeckDetailViewController alloc] initWithNibName:@"DeckDetailView" bundle:nil];
	}
	deckDetailViewController.title = [deck getDeckTitle];
	deckDetailViewController.deck = deck;
	deckDetailViewController.database = database;
	[self.navigationController pushViewController:deckDetailViewController animated:YES];	
	
	[deck release];	
}

#pragma mark -
#pragma mark Table Edit Methods


- (IBAction)editTable:(id)sender
{
	if(self.editing) // if already editing, quit
	{
		[super setEditing:NO animated:NO];
		[libraryTableView setEditing:NO animated:NO];
		[libraryTableView reloadData];
		[self.navigationItem.leftBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStylePlain];
	}
	else // else start editing
	{
		[super setEditing:YES animated:YES];
		[libraryTableView setEditing:YES animated:YES];
		[libraryTableView reloadData];
		[self.navigationItem.leftBarButtonItem setTitle:@"Done"];
		[self.navigationItem.leftBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Done"]) // if currently editing, do not show Delete
	{
		return UITableViewCellEditingStyleNone;
	}
	else // otherwise - user has swiped - show delete
	{
		return UITableViewCellEditingStyleDelete;
	}
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	int oldPosition = fromIndexPath.row + 1; // row is 0-based; DB positions are 1-based
	int newPosition = toIndexPath.row + 1;

	// Only process if deck was moved to a new position
	if (oldPosition != newPosition)
	{
		// update database
			DeckDetails *movedDeckDetails = [[localLibraryDetails objectAtIndex:fromIndexPath.row] retain];
			int DBDeckID = movedDeckDetails.deckID;
		
			// find the DB position of the deck in the destination position (this is necessary as DB positions do not maintain sequential ordering following e.g. deck deletions)
			const char *sqlStatement = "SELECT MAX(position) FROM (SELECT id, position FROM Deck ORDER BY position ASC LIMIT ?)";
			sqlite3_stmt *compiledStatement;
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
			{
				sqlite3_bind_int(compiledStatement, 1, newPosition);
				while(sqlite3_step(compiledStatement) == SQLITE_ROW)
				{
					newPosition = (int)sqlite3_column_int(compiledStatement, 0);					
				}
			}
		
			// move all decks that weren't the deck explicitly moved
			sqlite3_stmt *updateStmt = nil;
			if(updateStmt == nil)
			{
				const char *sql;
				if (newPosition > oldPosition)
				{sql = "UPDATE Deck SET position = position-1 WHERE position > ? AND position <= ?";}
				else
				{sql = "UPDATE Deck SET position = position + 1 WHERE position < ? AND position >= ?";}
				if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
					NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				NSLog(@"Error: updatestmt not nil");
			}
			sqlite3_bind_int(updateStmt, 1, oldPosition);
			sqlite3_bind_int(updateStmt, 2, newPosition);
			if(SQLITE_DONE != sqlite3_step(updateStmt))
			{NSAssert1(0, @"Error while updating DB with new position. '%s'", sqlite3_errmsg(database));}
			sqlite3_reset(updateStmt);
			updateStmt = nil;
			
			// move the deck explicitly moved
			if(updateStmt == nil)
			{
				const char *sql;
				sql = "UPDATE Deck SET position = ? WHERE id = ?";
				if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
					NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
			}
			else
			{
				NSLog(@"Error: updatestmt not nil");
			}
			sqlite3_bind_int(updateStmt, 1, newPosition);
			sqlite3_bind_int(updateStmt, 2, DBDeckID);
			if(SQLITE_DONE != sqlite3_step(updateStmt))
			{NSAssert1(0, @"Error while updating DB with new position. '%s'", sqlite3_errmsg(database));}
			sqlite3_reset(updateStmt);		
			updateStmt = nil;
		
		// update localLibraryDetails
			[localLibraryDetails removeObject:movedDeckDetails];
			[localLibraryDetails insertObject:movedDeckDetails atIndex:toIndexPath.row];
			[movedDeckDetails release];
	}
}


#pragma mark -
#pragma mark Row Deletion Methods

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// If row is deleted, remove it from the list.
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// get the DeckID for deletion
		uint rowIndex = [indexPath row];
		DeckDetails *deckDetailsForDeletion = (DeckDetails *)[localLibraryDetails objectAtIndex:(rowIndex)];
		uint deckIDToDelete = deckDetailsForDeletion.deckID;

		// delete the deck from localLibraryDetails (which feeds the table)
		[localLibraryDetails removeObjectAtIndex:rowIndex];
		
		// delete the deck from the database (DB cascades deletions)
		NSString *deletionString = [NSString stringWithFormat:@"DELETE FROM Deck WHERE id = %d", deckIDToDelete];
		[self runDeletionWithSQL:deletionString];
				
		// Animate the deletion from the table.
		[libraryTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		// update the table footer
		[self updateTableSettingsBasedOnNumberOfDecks];
	}
}


#pragma mark -
#pragma mark Action Methods

-(void)pushFeedbackScreen:(id)sender
{
}

- (IBAction)pushDownloadScreen:(id)sender
{
	DownloadViewController *downloadViewController = [[DownloadViewController alloc] initWithNibName:@"DownloadView" bundle:nil];
	downloadViewController.title = @"Download";
	downloadViewController.database = database;
	//downloadViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:downloadViewController animated:YES];
	[downloadViewController release];	
}

- (IBAction)syncDecksWithServer:(id)sender
{
	// setup URL
	NSURL *url = [NSURL URLWithString:[CONTEXT_URL stringByAppendingString:[NSString stringWithFormat:@"/decks"]]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	// check for credentials in the keychain
	NSURLCredential *authenticationCredentials = [ASIHTTPRequest savedCredentialsForHost:[[request url] host] port:[[[request url] port] intValue] protocol:[[request url] scheme] realm:[request authenticationRealm]];
	if (authenticationCredentials) // if credentials exist, request the deck list
	{
		// show busy indicator
		[ProgressViewController startShowingProgress];
		// send request
		[request setUsername:[authenticationCredentials user]];
		[request setPassword:[authenticationCredentials password]];
		[request setDelegate:self];
		[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[authenticationCredentials user], @"username", nil]];
		[request setDidFinishSelector:@selector(deckListRequestFinished:)];
		[request setDidFailSelector:@selector(deckListRequestFailed:)];
		[request startAsynchronous];		
	}
	else // no credentials exist, so ask for them
	{
		[ASIAuthenticationDialog presentAuthenticationDialogForRequest:request delegate:self username:@"" repeatAttempt:NO];		
		//[ASIAuthenticationDialog performSelectorOnMainThread:@selector(presentAuthenticationDialogForRequest:) withObject:self waitUntilDone:[NSThread isMainThread]];
	}
}

- (void) credentialsEntered
{
	// have another go at syncing, using the newly entered credentials
	//[self.navigationController popViewControllerAnimated:YES];
	[self syncDecksWithServer:self];
}

- (void) deckListRequestFinished:(ASIHTTPRequest *)request
{
	DDXMLDocument *doc;
	NSString *responseString = [request responseString];
	doc = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
	if (doc == nil)	{[doc release];	return;}

	DDXMLElement *rootElement = [doc rootElement];
	if ([XML_ERROR_TAG isEqualToString:[rootElement name]]) // if the server returned an error...
	{
		// remove busy indicator
		[ProgressViewController stopShowingProgress];		
		
		// what are the specifics of the failure?
		BOOL userRecognised = [[[[rootElement elementsForName:@"logon_succeeded"] objectAtIndex:0] stringValue] boolValue];
		NSString *username = [request.userInfo valueForKey:@"username"];
		
		// if the error was due to a failed logon, show the credentials dialog
		if (!(userRecognised))
		{
			[ASIAuthenticationDialog presentAuthenticationDialogForRequest:request delegate:self username:username repeatAttempt:YES];
		}
		else // otherwise, just notify the user of the failure
		{
			NSString *error_description = [[[rootElement elementsForName:@"description"] objectAtIndex:0] stringValue];
			[MindEggUtilities mindEggErrorAlertWithMessage:error_description];
		}
	}
	else // the server returned the deck summary information, so process this and then ask for the full deck
	{
		// populate database based on retrieved xml_string
		int numberDecksReceived = [[doc rootElement] childCount];
		
		// remove busy indicator for now (deckparser will put it back on for each individual deck download - the gap shouldn't be noticeable to the user)
		[ProgressViewController stopShowingProgress];
		
		// loop through the decks received
		for (int i = 0; i <numberDecksReceived; i++)
		{
			
			// find this deck's user_visible_id
			int userVisibleID = [[[[(DDXMLElement *)[[doc rootElement] childAtIndex:i] elementsForName:@"user_visible_id"] objectAtIndex: 0] stringValue] integerValue];
			
			// check if this deck already exists on iphone
			BOOL deckExistsAlready = NO;
			const char *sqlStatement = "SELECT user_visible_id FROM Deck WHERE user_visible_id =?;";
			sqlite3_stmt *compiledStatement;
			if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
			{
				sqlite3_bind_int(compiledStatement,1,userVisibleID);
				while(sqlite3_step(compiledStatement) == SQLITE_ROW) // if a row is returned
				{
					deckExistsAlready = YES;
				}
			}
			// Release the compiled statement from memory
			sqlite3_finalize(compiledStatement);
					
			// if the deck doesn't already exist, retrieve it
			if (!(deckExistsAlready))
			{
				DeckParser *deckParser = [[DeckParser alloc] init];
				[deckParser getDeckWithUserDeckID:userVisibleID intoDB:database];
			}
		}
	}
	
	// clean up
	[doc release];
}

- (void) deckListRequestFailed:(ASIHTTPRequest *)request
{
	// remove busy indicator
	[ProgressViewController stopShowingProgress];

	// tell user that there was a problem and that decks are not being synchronised
 	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle:  [NSString stringWithFormat:@"Couldn't Synchronize Decks"]
							   message: [NSString stringWithFormat:@"Please check your network connection and try again."]
							   delegate: nil
							   cancelButtonTitle: @"OK"
							   otherButtonTitles: nil];
	[errorAlert show];
	[errorAlert release];
}


#pragma mark -
#pragma mark Other Methods

-(void)retrieveLocalLibraryDetails
{
	// Init the local library Array
	[localLibraryDetails release];
	localLibraryDetails = [[NSMutableArray alloc] init];

	// retrieve details of each deck from the DB
	const char *sqlStatement = "SELECT Deck.id, Deck.title, COUNT(DISTINCT all_cards.id), COUNT(DISTINCT known_cards.id), first_sides.first_side_id FROM Deck LEFT OUTER JOIN Card all_cards ON all_cards.deck_id = Deck.id LEFT OUTER JOIN (SELECT id as id, deck_id as deck_id FROM Card WHERE Card.known = 1) AS known_cards ON known_cards.deck_id = Deck.id LEFT OUTER JOIN (SELECT Side.id AS first_side_id, Card.deck_id AS deck_id FROM Card, Side WHERE Side.card_id = Card.id AND Card.orig_position = 1 AND Side.position = 1) AS first_sides ON first_sides.deck_id = Deck.id GROUP BY Deck.id ORDER BY Deck.position;";
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		// Process each returned row (== deck) in turn
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			// Read the data from the result row
			// deck id
			int deckID = (int)sqlite3_column_int(compiledStatement, 0);
			// title
			NSString *deckTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
			// number of cards
			int numCards = (int)sqlite3_column_int(compiledStatement, 2);
			// number of known cards
			int numKnownCards = (int)sqlite3_column_int(compiledStatement, 3);
			// first side of first card of deck
			int firstSideID = (int)sqlite3_column_int(compiledStatement, 4);
			
			// Create deck details object with extracted data & add to array
			DeckDetails *singleDeckDetails = [[DeckDetails alloc] initWithID:deckID firstSideID:firstSideID title:deckTitle numCards:numCards numKnownCards:numKnownCards];
			[localLibraryDetails addObject:singleDeckDetails];
			[singleDeckDetails release];
		}
	}
	
	// Release the compiled statement from memory
	sqlite3_finalize(compiledStatement);
	
}

- (NSInteger)numDecks
{
	int numberOfDecks;
	
	// Setup the SQL Statement and compile it for faster access
	const char *sqlStatement = "SELECT COUNT(*) FROM Deck;";
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		// Process each returned row (== deck) in turn
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			// Read the data from the result row
			numberOfDecks = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	
	// Release the compiled statement from memory
	sqlite3_finalize(compiledStatement);
	
	return numberOfDecks;	
}


-(void)runDeletionWithSQL:(NSString *)sqlString
{	
	if(deleteStmt == nil)
	{
		const char *sql = [sqlString UTF8String];
		if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
		{
			NSLog(@"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
		}
	}
	
	if (SQLITE_DONE != sqlite3_step(deleteStmt))
		NSLog(@"Error while deleting. '%s'", sqlite3_errmsg(database));
	
	sqlite3_reset(deleteStmt);
	deleteStmt = nil;
}


// Updates the view to:
// (1) Show the table if there is content or an image if there is not
// (2) show a table footer with the number of decks iff there are 4 or more decks
-(void)updateTableSettingsBasedOnNumberOfDecks
{
	uint numberDecks = [self numDecks];
	
	if (numberDecks == 0) // if there are no decks, show pretty image
	{
		if (libraryTableView.superview != nil) // if the table is shown in the view, remove it
		{
			[libraryTableView removeFromSuperview];			
		}
		
		if (noContentImageView == nil) // if the image is _not_ in the view, add it
		{
			noContentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoContent.png"]];
			noContentImageView.frame = CGRectMake(0,0,320,416);
			noContentImageView.contentMode = UIViewContentModeTop;
			[self.view addSubview:noContentImageView];			
		}
	}
	else // if there are decks...
	{
		if (noContentImageView)
		{
			[noContentImageView removeFromSuperview];
			noContentImageView = nil;
			[noContentImageView release];
		}
		
		if (libraryTableView.superview == nil) // if the table is _not in the view, add it
		{
			[self.view addSubview:libraryTableView];
		}
		
		// configure table footer
		if (numberDecks > 3) // if there are more than 3 decks, show the total number of decks
		{
			libraryTableView.tableFooterView = tableFooterViewController.view;
			tableFooterViewController.label.text = [NSString stringWithFormat: @"%d Decks", numberDecks];
		}
		else // if there are only 1-3 decks, don't bother showing the total number - user can see!
		{
			libraryTableView.tableFooterView = nil;
		}
	}
}

#pragma mark -
#pragma mark Memory Mangement Methods

- (void)didReceiveMemoryWarning {
	NSLog (@"MyDecksViewController received memory warning");
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[tableFooterViewController release];
	[localLibraryDetails release];
	[deckDetailViewController release];
    [super dealloc];
}


@end
