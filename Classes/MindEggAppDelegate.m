//
//  MindEggAppDelegate.m
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MindEggAppDelegate.h"
#import "StudyViewController.h"
#import "MyDecksViewController.h"
#import "DownloadViewController.h"
#import "FeedbackViewController.h"
#import "ReviseViewController.h"
#import "Constants.h"
#import "VariableStore.h"

@implementation MindEggAppDelegate

@synthesize window;

BOOL referenceMode = NO;
NSString *dbName = @"MindEgg.sqlite";

UINavigationController *navigationController;

#pragma mark -
#pragma mark Main Method

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	// set Look & Feel
	[application setStatusBarStyle:UIStatusBarStyleDefault];

	// Handle User Defaults File
	[self processUserDefaults];
	
	// Set up DB for use
	[self connectToDB:[self findDatabase]];
	
	// Create a navigation controller and push a Library view controller onto it
	navigationController = [[UINavigationController alloc] init];	
	MyDecksViewController *myDecksViewController = [MyDecksViewController sharedInstance];
	myDecksViewController.title = @"Quack";
	[navigationController pushViewController:myDecksViewController animated:NO];
	navigationController.navigationBar.barStyle = UIBarStyleDefault; //UIBarStyleBlackOpaque;
	
    [window addSubview:navigationController.view];
	[window makeKeyAndVisible];
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
		NSLog(defaultDBPath);
		NSLog(dbPath);
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
	
	// Store the database pointer as a global variable
	[VariableStore sharedInstance].database = db;
}

#pragma mark -
#pragma mark Tidy Up Methods

- (void)applicationWillTerminate:(UIApplication *)application
{
	sqlite3_close([VariableStore sharedInstance].database);
}

- (void)dealloc {
	[navigationController release];
    [window release];
    [super dealloc];
}


@end
