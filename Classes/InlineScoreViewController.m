//
//  InlineScoreViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InlineScoreViewController.h"

static InlineScoreViewController *sharedInlineScoreViewController = nil;

@implementation InlineScoreViewController

@synthesize topMultipartLabel, bottomMultipartLabel;

// manage the shared instance of this singleton View Controller
+ (InlineScoreViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedInlineScoreViewController)
		{
			sharedInlineScoreViewController = [[[self class] alloc] initWithNibName:@"InlineScoreView" bundle:nil];
		}
	}
    return sharedInlineScoreViewController;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}


@end
