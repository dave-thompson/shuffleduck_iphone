//
//  ShuffleDuckAppDelegate.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "ShuffleDuckAppDelegate.h"
#import "StudyViewController.h"
#import "MyDecksViewController.h"
#import "DownloadViewController.h"
#import "FeedbackViewController.h"
#import "CongratulationsViewController.h"
#import "FinalScoreViewController.h"
#import "Constants.h"
#import "VariableStore.h"

@implementation ShuffleDuckAppDelegate

@synthesize window;

NSString *dbName = @"ShuffleDuck.sqlite";

UINavigationController *navigationController;

BOOL fullyFinishedLaunch = NO;

#pragma mark -
#pragma mark Main Method

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	// set Look & Feel
		[application setStatusBarStyle:UIStatusBarStyleDefault];

	// Handle User Defaults File
		[self processUserDefaults];
	
	// Set up DB
		[self connectToDB:[self findDatabase]];
	
	// Create a navigation controller and push a Library view controller onto it
		navigationController = [[UINavigationController alloc] init];	
		MyDecksViewController *myDecksViewController = [MyDecksViewController sharedInstance];
		myDecksViewController.title = @"";
		[navigationController pushViewController:myDecksViewController animated:NO];
		navigationController.navigationBar.barStyle = UIBarStyleDefault; //UIBarStyleBlackOpaque;
		
		[window addSubview:navigationController.view];
		[window makeKeyAndVisible];

	// Restore navigation status
	
		// retrieve status from DB
		NSString *screen;
		int addDeckDeckID;
		int deckID;
	
		NSString *sqlString = @"SELECT screen, add_deck_deck_id, deck_id FROM ApplicationStatus;";
		const char *sqlStatement = [sqlString UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
		{
			while(sqlite3_step(compiledStatement) == SQLITE_ROW)
			{
				screen = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				addDeckDeckID =  (int)sqlite3_column_int(compiledStatement, 1);
				deckID =  (int)sqlite3_column_int(compiledStatement, 2);
			}
		}
		else
		{
			NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
		}

		// navigate to required screen
		if ([screen isEqualToString:@"add_deck"])
		{
			[navigationController pushViewController:[DownloadViewController sharedInstance] animated:NO];
			[DownloadViewController sharedInstance].deckID = addDeckDeckID;
		}
		else if ([screen isEqualToString:@"deck_detail"])
		{
			[[MyDecksViewController sharedInstance] pushDeckDetailViewControllerWithDeckID:deckID asPartOfLoadProcess:YES];
		}
		else if ([screen isEqualToString:@"view"])
		{
			[[MyDecksViewController sharedInstance] pushDeckDetailViewControllerWithDeckID:deckID asPartOfLoadProcess:YES];
			[[DeckDetailViewController sharedInstance] pushStudyViewController:View asPartOfApplicationLoadProcess:YES];
		}
		else if ([screen isEqualToString:@"learn"])
		{
			[[MyDecksViewController sharedInstance] pushDeckDetailViewControllerWithDeckID:deckID asPartOfLoadProcess:YES];
			[[DeckDetailViewController sharedInstance] pushStudyViewController:Learn asPartOfApplicationLoadProcess:YES];
		}
		else if ([screen isEqualToString:@"test"])
		{
			[[MyDecksViewController sharedInstance] pushDeckDetailViewControllerWithDeckID:deckID asPartOfLoadProcess:YES];
			[[DeckDetailViewController sharedInstance] pushStudyViewController:Test asPartOfApplicationLoadProcess:YES];
		}
		else if ([screen isEqualToString:@"congratulations"])
		{
			[[MyDecksViewController sharedInstance] pushDeckDetailViewControllerWithDeckID:deckID asPartOfLoadProcess:YES];
			[[DeckDetailViewController sharedInstance] pushStudyViewController:Learn asPartOfApplicationLoadProcess:YES];
			[[StudyViewController sharedInstance] pushCongratulationsViewControllerAsPartofApplicationLoadProcess:YES];
		}
		else if ([screen isEqualToString:@"final_score"])
		{
			[[MyDecksViewController sharedInstance] pushDeckDetailViewControllerWithDeckID:deckID asPartOfLoadProcess:YES];
			[[DeckDetailViewController sharedInstance] pushStudyViewController:Test asPartOfApplicationLoadProcess:YES];
			[[StudyViewController sharedInstance] pushFinalScoreViewControllerAsPartofApplicationLoadProcess:YES];
		}
		else if ([screen isEqualToString:@"help"])
		{
		}
	
	fullyFinishedLaunch = YES;	
}

#pragma mark -
#pragma mark User Defaults Methods

- (void) processUserDefaults
{
	// remove the user's credentials from the keychain if the user has asked to reset them
	BOOL resetAccount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"resetAccount"] boolValue];
	if (resetAccount)
	{
		// create a dummy request to identify the credentials' location in the keychain
		NSURL *url = [NSURL URLWithString:[CONTEXT_URL stringByAppendingString:[NSString stringWithFormat:@"/decks"]]];
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
		// remove the credentials
		[ASIHTTPRequest removeCredentialsForHost:[[request url] host] port:[[[request url] port] intValue] protocol:[[request url] scheme] realm:[request authenticationRealm]];
		// reset the user defaults so that we don't do this again next time - unless the user specifically asks us to again
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"resetAccount"];
	}
}

#pragma mark -
#pragma mark Database Methods

- (NSString *)findDatabase
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	
	// get database file path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *dbPath = [documentsDir stringByAppendingPathComponent:dbName];	
	
	// if database not yet copied to filestore (i.e. this is first application launch), then copy it to the filestore
	BOOL dbExists = [fileManager fileExistsAtPath:dbPath];
	if(!dbExists)
	{
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
		dbExists = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
	}
	
	if(!dbExists) // if it still doesn't exist, something went wrong with the copy: log the problem
	{
		NSLog(@"Failed to create writeable database file with message '%@'.", [error localizedDescription]);
	}
	
	return dbPath;
}

- (void)connectToDB:(NSString *)dbPath
{
	sqlite3 *db;
	// open the database (to be kept open for application lifetime)
	if (sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK)
	{
		sqlite3_close(db);
		NSLog(@"Failed to open database");
	}
	
	// Tune the DB
		if(sqlite3_exec(db, "PRAGMA CACHE_SIZE=50", NULL, NULL, NULL) != SQLITE_OK)
			NSLog(@"Couldn't set cache size: %s", sqlite3_errmsg(db));

		if(sqlite3_exec(db, "PRAGMA synchronous = OFF", NULL, NULL, NULL) != SQLITE_OK)
			NSLog(@"Couldn't set synchronous OFF: %s", sqlite3_errmsg(db));

		if(sqlite3_exec(db, "PRAGMA journal_mode=MEMORY", NULL, NULL, NULL) != SQLITE_OK)
			NSLog(@"Couldn't set journal mode to MEMORY: %s", sqlite3_errmsg(db));

	// Store the database pointer as a global variable
	[VariableStore sharedInstance].database = db;
}

#pragma mark -
#pragma mark Tidy Up Methods

- (void)applicationWillTerminate:(UIApplication *)application
{
	if (fullyFinishedLaunch)
	{
	// Remember navigation state
		// Declare state variables
		NSString *screen = @"library";
		int addDeckDeckID = 0;
		int deckID = 0;
		
		// Find state
		if ([navigationController.topViewController isKindOfClass:[MyDecksViewController class]])
			screen = @"library";
		else if ([navigationController.topViewController isKindOfClass:[DownloadViewController class]])
		{
			screen = @"add_deck";
			addDeckDeckID = [[DownloadViewController sharedInstance] deckID];
		}
		//else if ([navigationController.topViewController isKindOfClass:[HelpViewController class]])
		//	screen = "help";
		else if ([navigationController.topViewController isKindOfClass:[DeckDetailViewController class]])
		{
			screen = @"deck_detail";
			deckID = [DeckDetailViewController sharedInstance].deck.currentDeckID;
		}
		else if ([navigationController.topViewController isKindOfClass:[StudyViewController class]])
		{
			switch ([[StudyViewController sharedInstance] getStudyType]) 
			{
				case View:
				{
					screen = @"view";
					break;
				}
				case Learn:
				{
					screen = @"learn";
					break;
				}
				case Test:
				{
					screen = @"test";
					break;
				}
			}
			deckID = [StudyViewController sharedInstance].deck.currentDeckID;
		}
		else if ([navigationController.topViewController isKindOfClass:[CongratulationsViewController class]])
		{
			screen = @"congratulations";
			deckID = [DeckDetailViewController sharedInstance].deck.currentDeckID;
		}
		else if ([navigationController.topViewController isKindOfClass:[FinalScoreViewController class]])
		{
			screen = @"final_score";		
			deckID = [DeckDetailViewController sharedInstance].deck.currentDeckID;
		}
			
		// Write state to DB
		NSString *sqlString = [NSString stringWithFormat:@"UPDATE ApplicationStatus SET screen = '%@', add_deck_deck_id = %d, deck_id = %d", screen, addDeckDeckID, deckID];
		sqlite3_stmt *updateStmt = nil;
		if(updateStmt == nil)
		{
			const char *sql = [sqlString UTF8String];
			if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
				NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
		}
		else
		{
			NSLog(@"Error: updatestmt not nil");
		}
		if(SQLITE_DONE != sqlite3_step(updateStmt))
		{NSAssert1(0, @"sqlite error: '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));}
		sqlite3_reset(updateStmt);
		updateStmt = nil;
	}
		
	// clean up DB connection
	sqlite3_close([VariableStore sharedInstance].database);
}

- (void)dealloc {
	[navigationController release];
    [window release];
    [super dealloc];
}


@end
