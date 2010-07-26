//
//  FeedbackViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

@interface FeedbackViewController : UIViewController {

	IBOutlet PlaceholderTextView *messageTextView;
	IBOutlet PlaceholderTextView *emailTextView;
}

+ (FeedbackViewController *)sharedInstance;

@end
