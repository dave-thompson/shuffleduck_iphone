//
//  FinalScoreViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FinalScoreViewController : UIViewController
{
	IBOutlet UILabel *percentLabel;
	IBOutlet UILabel *actualScoreLabel;
	IBOutlet UILabel *potentialScoreLabel;
	
	int percent;
	int actualScore;
	int potentialScore;
}

-(IBAction)studyButtonClicked:(id)sender;

@property (nonatomic, assign) int percent;
@property (nonatomic, assign) int actualScore;
@property (nonatomic, assign) int potentialScore;

@end
