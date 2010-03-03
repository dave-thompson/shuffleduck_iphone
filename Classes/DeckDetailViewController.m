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
#import "ContinueTestViewController.h"

static DeckDetailViewController *sharedDeckDetailViewController = nil;

@implementation DeckDetailViewController

@synthesize deck;

SideViewController *miniSideViewController;

// manage the shared instance of this singleton View Controller
+ (DeckDetailViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedDeckDetailViewController)
		{
			sharedDeckDetailViewController = [[[self class] alloc] initWithNibName:@"DeckDetailView" bundle:nil];
		}
	}
    return sharedDeckDetailViewController;
}

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
	[self pushStudyViewController:Test asPartOfApplicationLoadProcess:NO];
}

-(IBAction)studyButtonClicked:(id)sender
{
	[self pushStudyViewController:Learn asPartOfApplicationLoadProcess:NO];
}

-(IBAction)viewButtonClicked:(id)sender
{
	[self pushStudyViewController:View asPartOfApplicationLoadProcess:NO];
}


-(void)pushStudyViewController:(StudyType)type asPartOfApplicationLoadProcess:(BOOL)fromLoadProcess
{
	int questionNumber;
	// if user just selected to start a test and a test is already in progress, check with the user to see if they want to resume or start a new test
	if ((!fromLoadProcess) && ((type == Test) && ([deck testIsInProgress]) && ((questionNumber = (deck.numCards - deck.testQuestionsRemaining) + 1) > 1)))
	{
		// push screen to ask if user wants to resume
		ContinueTestViewController *continueTestViewController = [ContinueTestViewController sharedInstance];
		continueTestViewController.deck = deck;
		[continueTestViewController setScoreString:[NSString stringWithFormat:@"Q%d of %d", questionNumber, deck.numCards]];
		[self.navigationController pushViewController:continueTestViewController animated:YES];				
	}
	else
	{
		if ((type == Test) && (!fromLoadProcess)) // no test in progress, therefore start a new one
		{
			// prepare deck for new test
			[deck prepareTest];
		}

		// Prepare the study view controller (referencing the new deck object)
		StudyViewController *studyViewController = [StudyViewController sharedInstance];
		studyViewController.deck = deck;
		[studyViewController setStudyType:type];
		
		// Push the study view controller onto the navigation stack
		if (!fromLoadProcess)
			[self.navigationController pushViewController:studyViewController animated:YES];
		else
		{
			// set up back button (viewDidLoad will not have fired yet)
			UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
			self.navigationItem.backBarButtonItem = backArrowButton;
			[backArrowButton release];	
			// push view controller
			[self.navigationController pushViewController:studyViewController animated:NO];
		}
	}
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

	// set numbers to standard colours
	knownCardsLabel.textColor = [[VariableStore sharedInstance] mindeggGreen];
	unknownCardsLabel.textColor = [[VariableStore sharedInstance] mindeggRed];
	
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
	[miniSideViewController replaceSideWithSideID:firstSideID];
	miniSideViewController.view.frame = CGRectMake(1, 1, 104, 64);
	[firstCardView addSubview:miniSideViewController.view];
	
	// Disable / Enable buttons	
		// Only enable study button if there's at least 1 unknown card to study
		if (numUnknownCards == 0)	studyButton.enabled = NO;
		else						studyButton.enabled = YES;

		// Only enable test / view buttons if there's at least 1 card in the deck to be tested on / view
		if (numCards == 0)
		{
			testButton.enabled = NO;
			viewButton.enabled = NO;
		}
		else
		{
			testButton.enabled = YES;
			viewButton.enabled = YES;
		}
		
		// only enable shuffle buttons if there are at least 2 cards in the deck to shuffle; additionaly only enable unshuffle button if the cards are already shuffled
		if (numCards < 2)
		{
			shuffleButton.enabled = NO;
			unshuffleButton.enabled = NO;
		}
		else
		{
			shuffleButton.enabled = YES;
			if ([deck isShuffled])	unshuffleButton.enabled = YES;
			else					unshuffleButton.enabled = NO;
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
