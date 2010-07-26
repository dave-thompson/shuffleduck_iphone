//
//  ContinueTestViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface ContinueTestViewController : UIViewController {
	Deck *deck;
	IBOutlet UILabel *scoreLabel;
}

@property (nonatomic, retain) Deck *deck;
@property (nonatomic, retain) UILabel *scoreLabel;

+ (ContinueTestViewController *)sharedInstance;

-(IBAction)newButtonClicked:(id)sender;
-(IBAction)continueButtonClicked:(id)sender;
-(void)pushStudyViewController;
-(void)setScoreString:(NSString *)string;

@end
