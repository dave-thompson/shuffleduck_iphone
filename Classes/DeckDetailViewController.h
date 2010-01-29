//
//  DeckDetailViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "Deck.h"
#import "StudyViewController.h"

@interface DeckDetailViewController : UIViewController {

	IBOutlet UIButton *unshuffleButton;
	IBOutlet UIButton *shuffleButton;
	IBOutlet UIButton *studyButton;
	IBOutlet UIButton *testButton;
	
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *totalCardsLabel;	
	IBOutlet UILabel *knownCardsLabel;
	IBOutlet UILabel *unknownCardsLabel;
	IBOutlet UIView *firstCardView;
	
	IBOutlet UILabel *deckIdLabel;
	IBOutlet UILabel *authorLabel;
	
	Deck *deck;
	sqlite3 *database;
}

@property (nonatomic, retain) Deck *deck;
@property (nonatomic, assign) sqlite3 *database;

+ (DeckDetailViewController *)sharedInstance;

-(IBAction)shuffleButtonClicked:(id)sender;
-(IBAction)unshuffleButtonClicked:(id)sender;
-(IBAction)testButtonClicked:(id)sender;
-(IBAction)studyButtonClicked:(id)sender;
-(void)pushStudyViewController:(StudyType)type;

@end
