//
//  StudyViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#define kMinimumGestureLength		25
#define kMaximumVarianceInDegrees	35

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Deck.h"

@class SideViewController;

@interface StudyViewController : UIViewController <UISearchBarDelegate> {
	
	IBOutlet UIView *outerView;
	
	IBOutlet UISearchBar *searchBar;
	IBOutlet UIView *searchBarView;

	IBOutlet UIButton *tickButton;
	IBOutlet UIButton *crossButton;
	
	Deck *deck;
	sqlite3 *database;
}

typedef enum {
	Learn, // study view being used to memorize cards
	Test,  // study view being used to test a deck
} StudyType;


@property (nonatomic, retain) Deck *deck;
@property (nonatomic, assign) sqlite3 *database;

+ (StudyViewController *)sharedInstance;

-(IBAction)bottomButtonClicked:(id)sender;
//-(void)setBackgroundColor;
-(void)setStudyType:(StudyType)studyType;
//-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
//-(IBAction)showSearchBar:(id)sender;
//-(void)hideSearchBar;
-(void)showNewCard;
-(void)updateInlineScore;

@end
