//
//  MyDecksViewController.h
//  ShuffleDuck
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
	IBOutlet UIBarButtonItem *syncButton;
	
	IBOutlet UILabel *messageLabel;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

+ (MyDecksViewController *)sharedInstance;
- (void) refreshTable;
- (void) updateTableSettingsBasedOnNumberOfDecks;
- (void) retrieveLocalLibraryDetails;
- (NSInteger) numDecks;
- (void)loadSidesForOnscreenRows;

- (void)pushDeckDetailViewControllerWithDeckID:(int)deckID asPartOfLoadProcess:(BOOL)partOfLoadProcess;

- (IBAction)syncDecksWithServer:(id)sender;
- (IBAction)pushDownloadScreen:(id)sender;

-(void)showMessage:(NSString *)message;
-(void)hideMessages;

@property (nonatomic, retain) UIBarButtonItem *syncButton;

@end
