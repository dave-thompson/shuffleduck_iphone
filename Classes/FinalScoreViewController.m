//
//  FinalScoreViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FinalScoreViewController.h"
#import "MindEggAppDelegate.h"
#import "VariableStore.h"

static FinalScoreViewController *sharedFinalScoreViewController = nil;

@implementation FinalScoreViewController

@synthesize deck;

// manage the shared instance of this singleton View Controller
+ (FinalScoreViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedFinalScoreViewController)
		{
			sharedFinalScoreViewController = [[[self class] alloc] initWithNibName:@"FinalScoreView" bundle:nil];
		}
	}
    return sharedFinalScoreViewController;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	// set up view details				
	self.title = @"";
	self.hidesBottomBarWhenPushed = YES;
	
	// set numbers to standard colours
	correctScoreLabel.textColor = [[VariableStore sharedInstance] mindeggGreen];
	incorrectScoreLabel.textColor = [[VariableStore sharedInstance] mindeggRed];	
	
	// call super
    [super viewDidLoad];
}

-(IBAction)studyButtonPressed:(id)sender
{
	[[DeckDetailViewController sharedInstance] pushStudyViewController:Learn asPartOfApplicationLoadProcess:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// set the scores
	int cardsCompleted = deck.cardsCompleted;
	int cardsCorrect = deck.cardsCorrect;
	float floatPercent = ((float)deck.cardsCorrect / (float)cardsCompleted) * 100.0;
	int percent = (int)floatPercent; // 100% is only awarded if all Qs answered correctly (int cast appears to round down)
	int incorrectScore = cardsCompleted - cardsCorrect;
	int correctScore = cardsCorrect;
		
	// set up score labels
	percentLabel.text = [NSString stringWithFormat: @"%d%%", percent];
	correctScoreLabel.text = [NSString stringWithFormat: @"%d", correctScore];
	incorrectScoreLabel.text = [NSString stringWithFormat: @"%d", incorrectScore];	
	
	// enable / disable Learn button
	if (([deck numCards] - [deck numKnownCards]) == 0) // if there are no cards left to learn (note there may be no cards left to learn, even though the test score may not be 100% - this scenario arises where the user interrupts their test to learn those cards they missed, then resumes the test having marked those cards as Known using Learn mode)	
	{
		learnButton.enabled = NO;
	}
	else
	{
		learnButton.enabled = YES;
	}
	
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
	NSArray *oldVCArray = [self navigationController].viewControllers;
	NSMutableArray *newVCArray = [[NSMutableArray alloc] init];
	for (UIViewController *vc in oldVCArray)
	{
		if (!(vc == [StudyViewController sharedInstance]))
		{
			[newVCArray addObject:vc];
		}
	}
	[self navigationController].viewControllers = newVCArray;
	 
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
