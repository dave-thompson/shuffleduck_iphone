//
//  MyDecksViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
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

+(id)getMyDecksViewController;
-(void)refreshTable;
-(void)updateTableSettingsBasedOnNumberOfDecks;
-(void)retrieveLocalLibraryDetails;
-(void)popDaughterScreen;
-(void)runDeletionWithSQL:(NSString *)sqlString;
- (NSInteger)numDecks;
//-(IBAction)editTable:(id)sender;

@end
