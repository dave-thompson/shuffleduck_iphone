//
//  FinalScoreViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FinalScoreViewController.h"


@implementation FinalScoreViewController

@synthesize percent, actualScore, potentialScore;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	// set up score labels
	percentLabel.text = [NSString stringWithFormat: @"%d%%", percent];
	actualScoreLabel.text = [NSString stringWithFormat: @"%d", actualScore];
	potentialScoreLabel.text = [NSString stringWithFormat: @"%d", potentialScore];
		
	// call super
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(IBAction)studyButtonClicked:(id)sender
{
	// TO WRITE: POP AND PUSH SCREENS TO GET TO STUDY MODE
}

- (void)dealloc {
    [super dealloc];
}


@end
