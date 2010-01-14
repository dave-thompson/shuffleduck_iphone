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


@interface DeckDetailViewController : UIViewController {

	IBOutlet UIButton *unshuffleButton;
	
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *totalCardsLabel;	
	IBOutlet UILabel *knownCardsLabel;
	IBOutlet UILabel *unknownCardsLabel;
	IBOutlet UIView *firstCardView;
	
	Deck *deck;
	sqlite3 *database;
}

@property (nonatomic, retain) Deck *deck;
@property (nonatomic, assign) sqlite3 *database;

-(IBAction)shuffleButtonClicked:(id)sender;
-(IBAction)unshuffleButtonClicked:(id)sender;
-(IBAction)testButtonClicked:(id)sender;

@end
