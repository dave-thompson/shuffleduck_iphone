//
//  FinalScoreViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudyViewController.h"
#import "DeckDetailViewController.h"
#import "Deck.h"

@interface FinalScoreViewController : UIViewController
{
	IBOutlet UILabel *percentLabel;
	IBOutlet UILabel *correctScoreLabel;
	IBOutlet UILabel *incorrectScoreLabel;
	
	IBOutlet UIButton *learnButton;
	
	Deck *deck;	
}

@property (nonatomic, retain) Deck *deck;

+ (FinalScoreViewController *)sharedInstance;

-(IBAction)studyButtonPressed:(id)sender;

@end
