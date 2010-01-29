//
//  FinalScoreViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudyViewController.h"
#import "DeckDetailViewController.h"


@interface FinalScoreViewController : UIViewController
{
	IBOutlet UILabel *percentLabel;
	IBOutlet UILabel *correctScoreLabel;
	IBOutlet UILabel *incorrectScoreLabel;
	
	IBOutlet UIButton *learnButton;
	
	int percent;
	int correctScore;
	int incorrectScore;
}

+ (FinalScoreViewController *)sharedInstance;

-(IBAction)studyButtonPressed:(id)sender;

@property (nonatomic, assign) int percent;
@property (nonatomic, assign) int correctScore;
@property (nonatomic, assign) int incorrectScore;

@end
