//
//  TutorialViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface TutorialViewController : UIViewController {

	IBOutlet UIWebView *webView;
	StudyType studyType;
}

+ (TutorialViewController *)sharedInstance;

-(IBAction)okayButtonClicked:(id)sender;
-(IBAction)neverAgainButtonClicked:(id)sender;

@property (nonatomic, assign) StudyType studyType;

@end
