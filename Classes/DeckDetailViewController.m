//
//  DeckDetailViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DeckDetailViewController.h"
#import "VariableStore.h"
#import "SideViewController.h"

@implementation DeckDetailViewController

@synthesize deck, database;

SideViewController *miniSideViewController;

-(IBAction)shuffleButtonClicked:(id)sender
{
	[deck shuffle];
	unshuffleButton.enabled = YES;
}

-(IBAction)unshuffleButtonClicked:(id)sender
{
	[deck unshuffle];
	unshuffleButton.enabled = NO;
}

-(IBAction)testButtonClicked:(id)sender
{
	[self pushStudyViewController:Test];	
}

-(IBAction)studyButtonClicked:(id)sender
{
	[self pushStudyViewController:Learn];	
}

-(void)pushStudyViewController:(StudyType)type
{
	// Prepare a study view controller (referencing the new deck object)
	StudyViewController *studyViewController = [[StudyViewController alloc] initWithNibName:@"StudyView" bundle:nil];
	studyViewController.title = @"";
	studyViewController.deck = deck;
	studyViewController.database = database;
	[studyViewController setStudyType:type];
	studyViewController.hidesBottomBarWhenPushed = YES;
	
	// Push the study view controller onto the navigation stack
	[self.navigationController pushViewController:studyViewController animated:YES];
	
	// release allocated objects
	[studyViewController release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidLoad
{
	//setup custom back button
	UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
	self.navigationItem.backBarButtonItem = backArrowButton;
	[backArrowButton release];	

	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
	// derive deck statistics
	int numCards = [deck numCards];
	int numKnownCards = [deck numKnownCards];
	int numUnknownCards = numCards - numKnownCards;
	int firstSideID = [deck getOriginalFirstSideID];
	int userVisibleId = [deck userVisibleID];
	
	
	// Print deck information to screen
	titleLabel.text = [deck getDeckTitle];
	totalCardsLabel.text = [NSString stringWithFormat: @"%d", numCards];
	knownCardsLabel.text = [NSString stringWithFormat: @"%d", numKnownCards];
	unknownCardsLabel.text = [NSString stringWithFormat: @"%d", numUnknownCards];
	deckIdLabel.text = [NSString stringWithFormat: @"%d", userVisibleId];
	authorLabel.text = [deck author];
	
	miniSideViewController = [[SideViewController alloc] initWithNibName:@"SideView" bundle:nil];
	miniSideViewController.view.clipsToBounds = YES;
	[miniSideViewController setCustomSizeByWidth:104]; // height is 64; multiplier is 0.4
	[miniSideViewController replaceSideWithSideID:firstSideID FromDB:database];
	miniSideViewController.view.frame = CGRectMake(1, 1, 104, 64);
	[firstCardView addSubview:miniSideViewController.view];
	
	// if deck is not shuffled, disabled unshuffle button
	if ([deck isShuffled])
	{
		unshuffleButton.enabled = YES;
	}
	else
	{
		unshuffleButton.enabled = NO;
	}
	
	// make status bar blue
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault]; //UIStatusBarStyleBlackOpaque];
	
	// make navigation bar blue
	UINavigationController *navController = [self navigationController];
	navController.navigationBar.barStyle = UIBarStyleDefault; //UIBarStyleBlackOpaque;
}


- (void)dealloc {
	[deck release];
	[miniSideViewController release];
    [super dealloc];
}


@end
