//
//  InlineScoreViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InlineScoreViewController.h"


@implementation InlineScoreViewController

-(void)setTopLabelText:(NSString *)labelText
{
	topLabel.text = labelText;
}

-(void)setBottomLabelText:(NSString *)labelText
{
	bottomLabel.text = labelText;
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
