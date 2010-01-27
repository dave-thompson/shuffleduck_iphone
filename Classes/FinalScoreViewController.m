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
	
	
	// setup Study button
	UIBarButtonItem *studyButton = [[UIBarButtonItem alloc] initWithTitle:@"Study Missed Cards" style:UIBarButtonItemStyleBordered target:self action:@selector(studyButtonPressed:)]; 
	self.navigationItem.rightBarButtonItem = studyButton;
	[studyButton release];
	
	
	// call super
    [super viewDidLoad];
	
}

-(void)studyButtonPressed:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// make status bar black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// make navigation bar black
	UINavigationController *navController = [self navigationController];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;	
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
