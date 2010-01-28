//
//  ProgressViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *label;
}

@property (nonatomic, assign) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) UILabel *label;

+ (ProgressViewController *)sharedInstance;
+ (void)startShowingProgress;
+ (void)stopShowingProgress;

@end