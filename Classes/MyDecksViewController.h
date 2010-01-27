//
//  MyDecksViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "ASIHTTPRequest.h"

#import "StudyViewController.h"
#import "DeckDetailViewController.h"
#import "TableFooterViewController.h"

@interface MyDecksViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *localLibraryDetails;
	sqlite3 *database;	
	IBOutlet UITableView *libraryTableView;
	DeckDetailViewController *deckDetailViewController;
	TableFooterViewController *tableFooterViewController;
	UIImageView *noContentImageView;
}

@property (nonatomic, assign) sqlite3 *database;

+ (id) getMyDecksViewController;
- (void) refreshTable;
- (void) updateTableSettingsBasedOnNumberOfDecks;
- (void) retrieveLocalLibraryDetails;
- (void) runDeletionWithSQL:(NSString *)sqlString;
- (NSInteger) numDecks;
//-(IBAction)editTable:(id)sender;
- (void) credentialsEntered;
- (void) deckListRequestFailed:(ASIHTTPRequest *)request;
- (IBAction)pushDownloadScreen:(id)sender;
- (IBAction)syncDecksWithServer:(id)sender;


@end
