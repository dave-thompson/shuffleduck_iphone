//
//  TutorialViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TutorialViewController.h"
#import "ShuffleDuckUtilities.h"
#import "StudyViewController.h"
#import "ContinueTestViewController.h"

static TutorialViewController *sharedTutorialViewController = nil;

@implementation TutorialViewController

@synthesize studyType;

// manage the shared instance of this singleton View Controller
+ (TutorialViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedTutorialViewController)
		{
			sharedTutorialViewController = [[[self class] alloc] initWithNibName:@"TutorialView" bundle:nil];
		}
	}
    return sharedTutorialViewController;
}

- (void)viewDidLoad
{
	//setup custom back button
	UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
	self.navigationItem.backBarButtonItem = backArrowButton;
	[backArrowButton release];

	// set title
	self.title = @"Tutorial";
	
	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// load the appropriate content
	NSString *filePath;
	if (studyType == Learn)
	{
		filePath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TutorialLearn.html"];
	}
	else // studyType == Test
	{
		filePath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TutorialTest.html"];
	}
	NSURL *url = [NSURL fileURLWithPath:filePath];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
	
	// make status bar black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	
	// make navigation bar black
	UINavigationController *navController = [self navigationController];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// eliminate any view controllers that are on the stack between this one and the DeckDetail view controller
	NSArray *oldVCArray = [self navigationController].viewControllers;
	NSMutableArray *newVCArray = [[NSMutableArray alloc] init];
	for (UIViewController *vc in oldVCArray)
	{
		if (!(vc == [ContinueTestViewController sharedInstance]))
		{
			[newVCArray addObject:vc];
		}
	}
	[self navigationController].viewControllers = newVCArray;
	[newVCArray release];
}

-(IBAction)okayButtonClicked:(id)sender
{
	// push the study view controller (which should have already been set up appropriately)
	[self.navigationController pushViewController:[StudyViewController sharedInstance] animated:YES];
}


-(IBAction)neverAgainButtonClicked:(id)sender
{
	if (studyType == Learn)
		[ShuffleDuckUtilities runSQLUpdate:@"UPDATE ApplicationStatus SET tutorial_learn = 0"];		
	else // studyType == Test
		[ShuffleDuckUtilities runSQLUpdate:@"UPDATE ApplicationStatus SET tutorial_test = 0"];
	[self okayButtonClicked:self];
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
