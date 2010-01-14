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
#import "ASIHTTPRequest.h"
#import "DeckParser.h"
#import "VariableStore.h"
#import "ProgressViewController.h"
@implementation MyDecksViewController

@synthesize database;

static sqlite3_stmt *deleteStmt = nil;

static MyDecksViewController *myDecksViewController;


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
																	   target:self
																	   action:@selector(popDaughterScreen:)]; 
	self.navigationItem.backBarButtonItem = backArrowButton;
	[backArrowButton release];
	
	// setup download button
	UIBarButtonItem *downloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStyleBordered target:self action:@selector(pushDownloadScreen:)]; 
	self.navigationItem.rightBarButtonItem = downloadButton;
	[downloadButton release];
	
	// setup sync button
	UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self action:@selector(syncDecksWithServer:)]; 
	self.navigationItem.leftBarButtonItem = syncButton;
	[syncButton release];
	
	
	// create table footer
	tableFooterViewController = [[TableFooterViewController alloc] initWithNibName:@"TableFooterView" bundle:nil];
	
	/* RE-ORDERING DECKS DESCOPED
	 // SEE http[colon]//adeem.me/blog/2009/05/29/iphone-sdk-tutorial-part-5-add-delete-reorder-uitableview-rows/
	 // POSSIBLE USE OF EDIT FUNCTIONALITY TO REPLACE DOWNLOAD BUTTON, WITH GREEN ADD ROW OPTION....
	// setup edit button
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTable:)];
	[self.navigationItem setLeftBarButtonItem:editButton];
	[editButton release];
	*/
	
	myDecksViewController = self;
}

- (void)viewWillAppear:(BOOL)animated
{	
	// refresh table
	[self refreshTable];
	
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

-(void)popDaughterScreen
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table View Data Source Methods

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
	cell.subTitle.text = [NSString stringWithFormat: @"Cards: %d   Unknown: %d", currentCellDeck.numCards, currentCellDeck.numCards - currentCellDeck.numKnownCards];

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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int numberOfRows = [self numDecks];
	return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// return same height as that of LibraryCell...
	// .. but 1 greater than the height of LibraryCell's view
	return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// find the DB deck id for the selected row
	int selectedDeckIndex = [indexPath indexAtPosition:([indexPath length]-1)];
	DeckDetails* selectedDeckDetails = [localLibraryDetails objectAtIndex:selectedDeckIndex];
	int DBDeckID = selectedDeckDetails.deckID;
	
	// instantiate a deck object for this deck ID
	Deck *deck = [[Deck alloc] initWithDeckID:DBDeckID Database:database includeKnownCards:NO];
	
	// Prepare a study view controller (referencing the new deck object)
	StudyViewController *studyViewController = [[StudyViewController alloc] initWithNibName:@"StudyView" bundle:nil];
	studyViewController.title = @"";
	studyViewController.deck = deck;
	studyViewController.database = database;
	[studyViewController setStudyType:Learn];
	studyViewController.hidesBottomBarWhenPushed = YES;
	
	// Push the study view controller onto the navigation stack
	[self.navigationController pushViewController:studyViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// release allocated objects
	[studyViewController release];
	[deck release];
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
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

/*
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

// TO CO-EXIST WITH SWIPE DELETE, THIS MUST BE WRITTEN TO RETURN DELETE WHEN NOT EDITING AND NONE WHEN EDITING
// (CHECK STATUS OF EDIT BUTTON TO DETERMINE)
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// just want to allow reordering - display no button on left
	return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// update database
	// TO BE WRITTEN
	
	// update localLibraryDetails
	NSString *item = [[localLibraryDetails objectAtIndex:fromIndexPath.row] retain];
	[localLibraryDetails removeObject:item];
	[localLibraryDetails insertObject:item atIndex:toIndexPath.row];
	[item release];
}
*/

#pragma mark -
#pragma mark Row Deletion Methods

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// just want to allow reordering - display no button on left
	return UITableViewCellEditingStyleDelete;
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
		
		// delete the deck from the database (DB cascades deletions and updates positions)
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
	// show busy indicator
	[ProgressViewController startShowingProgress];
	
	// retrieve deck list
	NSURL *url = [NSURL URLWithString:[[[VariableStore sharedInstance] contextURL]stringByAppendingString:[NSString stringWithFormat:@"/decks"]]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(deckListRequestFinished:)];
	[request setDidFailSelector:@selector(deckListRequestFailed:)];
	[request startAsynchronous];
}

- (void) deckListRequestFinished:(ASIHTTPRequest *)request
{
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
			[deckParser getDeckWithUserDeckID:userVisibleID intoDB:database userProvidedID:NO];
		}
	}
	
	// clean up
	[doc release];
}

- (void) deckListRequestFailed:(ASIHTTPRequest *)request
{
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
