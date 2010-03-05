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
	IBOutlet UIView *bottomBarView;
	
	Deck *deck;
}

@property (nonatomic, retain) Deck *deck;

+ (StudyViewController *)sharedInstance;

-(IBAction)bottomButtonClicked:(id)sender;
-(void)setStudyType:(StudyType)studyType;
-(StudyType)getStudyType;
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
-(void)showNewCard;
-(void)updateInlineScore;
-(void)showNextSide;
-(void)hideCard;

-(void)pushCongratulationsViewControllerAsPartofApplicationLoadProcess:(BOOL)partOfLoadProcess;
-(void)pushFinalScoreViewControllerAsPartofApplicationLoadProcess:(BOOL)partOfLoadProcess;

@end
