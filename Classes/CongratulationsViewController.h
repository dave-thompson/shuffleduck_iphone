//
//  CongratulationsViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 01/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CongratulationsViewController : UIViewController
{
	IBOutlet UILabel *totalCardsLabel;
	
	int totalCards;
}

+ (CongratulationsViewController *)sharedInstance;

-(IBAction)testButtonPressed:(id)sender;

@property (nonatomic, assign) int totalCards;

@end
