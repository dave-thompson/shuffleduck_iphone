//
//  FinalScoreViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FinalScoreViewController.h"
#import "MindEggAppDelegate.h"


@implementation FinalScoreViewController

@synthesize percent, correctScore, incorrectScore;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	// set up view details				
	self.title = @"";
	self.hidesBottomBarWhenPushed = YES;
	
	// call super
    [super viewDidLoad];
}

-(IBAction)studyButtonPressed:(id)sender
{
	MindEggAppDelegate *appDelegate = (MindEggAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate closeFinalScoreView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// set up score labels
	percentLabel.text = [NSString stringWithFormat: @"%d%%", percent];
	correctScoreLabel.text = [NSString stringWithFormat: @"%d", correctScore];
	incorrectScoreLabel.text = [NSString stringWithFormat: @"%d", incorrectScore];	
	
	// make status bar blue
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault]; //UIStatusBarStyleBlackOpaque];
	
	// make navigation bar blue
	UINavigationController *navController = [self navigationController];
	navController.navigationBar.barStyle = UIBarStyleDefault; //UIBarStyleBlackOpaque;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// remove Study View Controller from the navigation stack so that the back button goes straight to Deck Details
	
	
}

-(void)viewDidDisappear:(BOOL)animated
{
	// wipe score from screen
	percentLabel.text = @"";
	correctScoreLabel.text = @"";
	incorrectScoreLabel.text = @"";
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

- (void)dealloc {
    [super dealloc];
}


@end
