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
	IBOutlet UITableView *libraryTableView;
	TableFooterViewController *tableFooterViewController;
	UIImageView *noContentImageView;
}

+ (MyDecksViewController *)sharedInstance;
- (void) refreshTable;
- (void) updateTableSettingsBasedOnNumberOfDecks;
- (void) retrieveLocalLibraryDetails;
- (void) runDeletionWithSQL:(NSString *)sqlString;
- (NSInteger) numDecks;
- (void) credentialsEntered;
- (void) deckListRequestFailed:(ASIHTTPRequest *)request;
- (IBAction)pushDownloadScreen:(id)sender;
- (IBAction)syncDecksWithServer:(id)sender;


@end
