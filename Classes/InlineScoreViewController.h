//
//  InlineScoreViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipartLabel.h"

@interface InlineScoreViewController : UIViewController {

	IBOutlet MultipartLabel *topMultipartLabel;
	IBOutlet MultipartLabel *bottomMultipartLabel;
}

+ (InlineScoreViewController *)sharedInstance;

@property (nonatomic, retain) MultipartLabel *topMultipartLabel;
@property (nonatomic, retain) MultipartLabel *bottomMultipartLabel;

@end
