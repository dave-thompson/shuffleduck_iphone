//
//  ContinueTestViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContinueTestViewController.h"
#import "StudyViewController.h"

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
	// Prepare the study view controller (referencing the new deck object)
	StudyViewController *studyViewController = [StudyViewController sharedInstance];
	studyViewController.deck = deck;
	[studyViewController setStudyType:Test];
	
	// Push the study view controller onto the navigation stack
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