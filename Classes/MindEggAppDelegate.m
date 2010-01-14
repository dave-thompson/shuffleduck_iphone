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

@implementation MindEggAppDelegate

@synthesize window;

BOOL referenceMode = NO;
NSString *dbName = @"MindEgg.sqlite";

UINavigationController *libraryNavController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// open DB connection and retrieve state data
	[self connectToDBAndRetrieveState];
	
	// set up the tab bar controller
	//tabBarController = [[UITabBarController alloc] init];
	//tabBarController.delegate = self;
	
	libraryNavController = [[UINavigationController alloc] init];
	
	MyDecksViewController *myDecksViewController = [[MyDecksViewController alloc] initWithNibName:@"MyDecksView" bundle:nil];
	myDecksViewController.title = @"MindEgg";
	myDecksViewController.database = database;
	[libraryNavController pushViewController:myDecksViewController animated:NO];
	//libraryNavController.tabBarItem.title = @"Library";
	//libraryNavController.tabBarItem.image = [UIImage imageNamed:@"library.png"];
	libraryNavController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	//FeedbackViewController *feedbackViewController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackView" bundle:nil];
	//feedbackViewController.title = @"Feedback";

	/* REVISE DESCOPED
	ReviseViewController *reviseViewController = [[ReviseViewController alloc] initWithNibName:@"ReviseView" bundle:nil];
	reviseViewController.title = @"Revise";
	*/
	
	// Add the view controllers to the tab bar controller
	//tabBarController.viewControllers = [NSArray arrayWithObjects:libraryNavController, feedbackViewController, nil];
		
    // Add tab bar controller's view to the window
	//[window addSubview:tabBarController.view];
    [window addSubview:libraryNavController.view];
	[window makeKeyAndVisible];

	// clean up memory
	//[feedbackViewController release];
	//[reviseViewController release];
	[myDecksViewController release];	
}


- (void) connectToDBAndRetrieveState
{
	
	// if this is the first time app has been loaded, copy the database to a writeable file area
	[self copyDatabaseIfNeeded];
	
	// open the database (to be kept open for application lifetime)
	if (sqlite3_open([dbPath UTF8String], &database) != SQLITE_OK)
	{
		sqlite3_close(database);
		NSLog(@"Failed to open database");
	}
	
	// retrieve application state from DB
		// Currently no state other than color, which is loaded from the DB locally by the respective view controllers
}

- (void) copyDatabaseIfNeeded
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	dbPath = [self getDBPath];
	BOOL dbExists = [fileManager fileExistsAtPath:dbPath];
	
	if(!dbExists) // if database not yet copied to filestore, then copy it to the filestore
	{
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
		dbExists = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		NSLog(defaultDBPath);
		NSLog(dbPath);
	}
		
	if(!dbExists) // if it still doesn't exist, something went wrong with the copy....
	{
		NSLog(@"Failed to create writeable database file with message '%@'.", [error localizedDescription]);
	}

	
}

- (NSString *)getDBPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:dbName];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	sqlite3_close(database);
}

- (void)dealloc {
	//[tabBarController release];
	[libraryNavController release];
    [window release];
    [super dealloc];
}


@end
