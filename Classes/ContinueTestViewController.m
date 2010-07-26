//
//  ContinueTestViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContinueTestViewController.h"
#import "StudyViewController.h"
#import "TutorialViewController.h"
#import "ShuffleDuckUtilities.h"

static ContinueTestViewController *continueTestViewController = nil;

@implementation ContinueTestViewController

@synthesize deck, scoreLabel;

NSString *scoreString = @"";

// manage the shared instance of this singleton View Controller
+ (ContinueTestViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!continueTestViewController)
		{
			continueTestViewController = [[[self class] alloc] initWithNibName:@"ContinueTestView" bundle:nil];
		}
	}
    return continueTestViewController;
}

-(void)setScoreString:(NSString *)string
{
	scoreString = string;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	scoreLabel.text = scoreString;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//setup custom back button
	UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
	self.navigationItem.backBarButtonItem = backArrowButton;
	[backArrowButton release];		
}

-(IBAction)newButtonClicked:(id)sender
{
	// prepare a new test and push the view controller
	[deck prepareTest];
	[self pushStudyViewController];
}

-(IBAction)continueButtonClicked:(id)sender
{
	// push the view controller to use the old test
	[self pushStudyViewController];
}

-(void)pushStudyViewController
{
	// Prepare the study view controller
	StudyViewController *studyViewController = [StudyViewController sharedInstance];
	studyViewController.deck = deck;
	[studyViewController setStudyType:Test];
	
	// push either the study view controller, or the tutorial screen that precedes it
	int showTutorialScreen = 0;
	showTutorialScreen = [ShuffleDuckUtilities getIntUsingSQL:@"SELECT tutorial_test FROM ApplicationStatus"];
	if (showTutorialScreen == 1) // if tutorial screen should be shown, push it
	{
		TutorialViewController *tutorialViewController = [TutorialViewController sharedInstance];
		tutorialViewController.studyType = Test;
		[self.navigationController pushViewController:tutorialViewController animated:YES];
	}
	else // otherwise, just push the study view directly
		[self.navigationController pushViewController:studyViewController animated:YES];
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
