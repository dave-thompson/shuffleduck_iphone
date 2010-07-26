//
//  CongratulationsViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 01/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CongratulationsViewController.h"
#import "ShuffleDuckAppDelegate.h"
#import "StudyViewController.h"
#import "VariableStore.h"
#import "DeckDetailViewController.h"

static CongratulationsViewController *sharedCongratulationsViewController = nil;

@implementation CongratulationsViewController

@synthesize totalCards;

// manage the shared instance of this singleton View Controller
+ (CongratulationsViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedCongratulationsViewController)
		{
			sharedCongratulationsViewController = [[[self class] alloc] initWithNibName:@"CongratulationsView" bundle:nil];
		}
	}
    return sharedCongratulationsViewController;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	// set up view details				
	self.title = @"";
	self.hidesBottomBarWhenPushed = YES;
	
	// set numbers to standard colours
	totalCardsLabel.textColor = [[VariableStore sharedInstance] mindeggGreen];
	
	// call super
    [super viewDidLoad];
}

-(IBAction)testButtonPressed:(id)sender
{
	[[DeckDetailViewController sharedInstance] pushStudyViewController:Test asPartOfApplicationLoadProcess:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// set up score labels
	totalCardsLabel.text = [NSString stringWithFormat: @"%d", totalCards];
	
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
	[newVCArray release];
}

-(void)viewDidDisappear:(BOOL)animated
{
	// wipe score from screen
	totalCardsLabel.text = @"";
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
