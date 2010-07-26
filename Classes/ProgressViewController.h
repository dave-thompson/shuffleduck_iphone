//
//  ProgressViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {

	IBOutlet UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

+ (ProgressViewController *)sharedInstance;

+ (void)startShowingProgress;
+ (void)stopShowingProgress;
+ (void)refresh;
@end
