//
//  StudyViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "StudyViewController.h"
#import "SideViewController.h"
#import "CardViewController.h"
#import "InlineScoreViewController.h"
#import "VariableStore.h"
#import "FinalScoreViewController.h"
#import "CongratulationsViewController.h"
#import "Constants.h"

static StudyViewController *sharedStudyViewController = nil;

@implementation StudyViewController

@synthesize deck;

// Background color variables
CGFloat red = 0.0;
CGFloat green = 0.0;
CGFloat blue = 0.0;

// Gesture detection
BOOL processedCurrentSwipe; // YES iff swipe completed but touch not yet completed
float kMaximumVariance; // As delta x / delta y
CGPoint gestureStartPoint; // Point the current gesture started at

// score tracking

	// Both types
	StudyType _studyType;
	StudyType _requestedStudyType;
	int numCards;

	// Study
	int cardsKnown = 0;

	// Test
	int cardsCompleted = 0;
	int cardsCorrect = 0;

CardViewController *topCardViewController, *bottomCardViewController;
InlineScoreViewController *inlineScoreViewController;

// ----- INITIALISERS ------

// manage the shared instance of this singleton View Controller
+ (StudyViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedStudyViewController)
		{
			sharedStudyViewController = [[[self class] alloc] initWithNibName:@"StudyView" bundle:nil];
		}
	}
    return sharedStudyViewController;
}


- (void)viewDidLoad
{
	// set up view
	self.title = @"";
	self.hidesBottomBarWhenPushed = YES;
	kMaximumVariance = tan(kMaximumVarianceInDegrees);

	// set up custom back button (going back to this screen will never be allowed, but this back button will allow subsequent screens to go back to DeckDetails)
	//setup custom back button
	UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
	self.navigationItem.backBarButtonItem = backArrowButton;
	[backArrowButton release];	

	// setup Card Side subviews
			topCardViewController = [[CardViewController alloc] initWithNibName:@"SideView" bundle:nil];
			topCardViewController.view.frame = CGRectMake(30, 16, 260, 160);
			[self.view insertSubview:topCardViewController.view atIndex:4];
	
			bottomCardViewController = [[CardViewController alloc] initWithNibName:@"SideView" bundle:nil];
			bottomCardViewController.view.frame = CGRectMake(30, 192, 260, 160);
			[self.view insertSubview:bottomCardViewController.view atIndex:4];
	
	// Set up the inline score view
	inlineScoreViewController = [InlineScoreViewController sharedInstance];
	UIBarButtonItem *scoreBarButton = [[UIBarButtonItem alloc] initWithCustomView:inlineScoreViewController.view];
	self.navigationItem.rightBarButtonItem = scoreBarButton; 
	[scoreBarButton release];
		
	// reposition search bar on top of cards
			[searchBarView retain];
			[searchBarView removeFromSuperview];
			[self.view insertSubview:searchBarView atIndex:2];
			[searchBarView release];
	 
	// set background color
	UIColor *color = [[VariableStore sharedInstance] backgroundColor];
	outerView.backgroundColor = color;
	topCardViewController.view.backgroundColor = color;
	bottomCardViewController.view.backgroundColor = color;
		
	//call super
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{	
	// make status bar black
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

	// make navigation bar black
	UINavigationController *navController = [self navigationController];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	// initiate state data
	processedCurrentSwipe = NO;
	numCards = deck.numCards;
	cardsKnown = deck.numKnownCards;
	cardsCompleted = 0;
	cardsCorrect = 0;
	[self updateInlineScore];
	
	// set up StudyType specifics
	
	if (_requestedStudyType == View)
	{
		if ((_studyType == Test) || (_studyType == Learn))
		{
			if (_studyType == Learn)
			{
				// convert from Learn to Test
					// add the cross button,  resize the tick button and ensure tick is green
					[bottomBarView addSubview:crossButton];
					tickButton.frame = CGRectMake(160, 0, 160, 49);
					[tickButton setImage:[UIImage imageNamed:@"GreenTick.png"] forState:UIControlStateNormal];							
			}
			// convert from Test to View
				[bottomBarView removeFromSuperview];
				searchBarView.frame = CGRectMake(0,0, 320, 44);
				topCardViewController.view.frame = CGRectMake(30, 60, 260, 160);
				bottomCardViewController.view.frame = CGRectMake(30, 236, 260, 160);
		}
		_studyType = View;
	}
	else if (_requestedStudyType == Learn)
	{
		if ((_studyType == View) || (_studyType == Test))
		{
			if (_studyType == View)
			{
				// convert from View to Test
				[outerView addSubview:bottomBarView];
				searchBarView.frame = CGRectMake(0, -44, 320, 44);
				topCardViewController.view.frame = CGRectMake(30, 16, 260, 160);
				bottomCardViewController.view.frame = CGRectMake(30, 192, 260, 160);
			}
			// convert from Test to Learn
				// remove the cross button, resize the tick button and ensure tick is white
				[crossButton removeFromSuperview];
				tickButton.frame = CGRectMake(0, 0, 320, 49);
				[tickButton setImage:[UIImage imageNamed:@"WhiteTick.png"] forState:UIControlStateNormal];
		}
		_studyType = Learn;
	}
	else // _requestedStudyType == Test
	{
		if (_studyType == Learn)
		{
			// add the cross button,  resize the tick button and ensure tick is green
			[bottomBarView addSubview:crossButton];
			tickButton.frame = CGRectMake(160, 0, 160, 49);
			[tickButton setImage:[UIImage imageNamed:@"GreenTick.png"] forState:UIControlStateNormal];			
		}
		else if (_studyType == View)
		{
			[outerView addSubview:bottomBarView];
			searchBarView.frame = CGRectMake(0, -44, 320, 44);
			topCardViewController.view.frame = CGRectMake(30, 16, 260, 160);
			bottomCardViewController.view.frame = CGRectMake(30, 192, 260, 160);
		}
		_studyType = Test;
	}
	
	//load first side of first card
	if (_studyType == Learn)
	{
		[deck moveToCardAtPosition:FirstCard includeKnownCards:NO];
	}
	else
	{
		[deck moveToCardAtPosition:FirstCard includeKnownCards:YES];
	}
	[self showNewCard];	
	
	// update score panel
	[self updateInlineScore];
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// eliminate any view controllers that are on the stack between this one and the DeckDetail view controller
	NSArray *oldVCArray = [self navigationController].viewControllers;
	NSMutableArray *newVCArray = [[NSMutableArray alloc] init];
	for (UIViewController *vc in oldVCArray)
	{
		if ((!(vc == [FinalScoreViewController sharedInstance])) && (!(vc == [CongratulationsViewController sharedInstance])))
		{
			[newVCArray addObject:vc];
		}
	}
	[self navigationController].viewControllers = newVCArray;
}

// setStudyType must be called before showing the view
// setStudyType does not have effect until viewWillAppear runs
-(void)setStudyType:(StudyType)studyType
{
	_requestedStudyType = studyType;
}

// ----- LOGIC METHODS -----

-(void)showNewCard
// Display a new card
// Before calling this method, call deck.nextCard to increment the card pointer (unless the deck is new; Deck instantiation automatically points to the first card).
{	
	// Top Card: Display the the current side of the current card
	[topCardViewController loadFrontSideWithDBSideID:deck.currentSideID];
	[topCardViewController setBackSideBlank];
	
	if ((_studyType == Learn) || (_studyType == Test))
	{
		// Bottom card: Leave empty pending user action
		[bottomCardViewController setFrontSideBlank];
		[bottomCardViewController setBackSideBlank];
	}
	else // _studyType == View
	{
		// Bottom Card: Show the second side of the current card
		[deck nextSide];
		[bottomCardViewController loadFrontSideWithDBSideID:deck.currentSideID];
		[bottomCardViewController setBackSideBlank];
	}
	
	// Reset the bottom tick to white if in study mode
	if (_studyType == Learn)
	{
		[tickButton setImage:[UIImage imageNamed:@"WhiteTick.png"] forState:UIControlStateNormal];
	}
}

-(void)showNewCardWithAnimation:(CardViewAnimation)direction
// Display a new card with a slide animation
// Before calling this method, call deck.nextCard to increment the card pointer (unless the deck is new; Deck instantiation automatically points to the first card).
{
	// Load new card onto hidden side views
	[topCardViewController loadBackSideWithDBSideID:[deck getCurrentSideID]];
	if (_studyType == View)
	{
		[deck nextSide];
		[bottomCardViewController loadBackSideWithDBSideID:[deck getCurrentSideID]];
	}
	else
		[bottomCardViewController setBackSideBlank];
	
	// transition to hidden sides
	[topCardViewController revealHiddenSide:direction];
	[bottomCardViewController revealHiddenSide:direction];
	
	// Reset the bottom button colours
	if (_studyType == Learn)
	{
		[tickButton setImage:[UIImage imageNamed:@"WhiteTick.png"] forState:UIControlStateNormal];
	}
}

// ----- GESTURE METHODS -----

-(void)processRightSwipe
{
	// ignore swipes in Test mode
	// && only process swipe if not already done so
	// && ignore swipe if the last swipe animation hasn't finished
	if ((((_studyType == Learn) || (_studyType == View)) && (processedCurrentSwipe == NO)) && ((topCardViewController.animationInProgress == NO) && (bottomCardViewController.animationInProgress == NO)))
	{
		BOOL additionalCardExists;
		if (_studyType == Learn)
			{additionalCardExists = [deck moveToCardInDirection:PreviousCard includeKnownCards:NO];}
		else // _studyType == View
			{additionalCardExists = [deck moveToCardInDirection:PreviousCard includeKnownCards:YES];}
		if (additionalCardExists == YES) // if there's a card in this deck other than the one already displayed
		{
			[self showNewCardWithAnimation:CardViewAnimationSlideRight];
		}
		processedCurrentSwipe = YES;
	}
}

-(void)processLeftSwipe
{
	// ignore swipes in Test mode
	// && only process swipe if not already done so
	// && ignore swipe if the last swipe animation hasn't finished
	if ((((_studyType == Learn) || (_studyType == View)) && (processedCurrentSwipe == NO)) && ((topCardViewController.animationInProgress == NO) && (bottomCardViewController.animationInProgress == NO)))
	{
		BOOL additionalCardExists;
		if (_studyType == Learn)
			{additionalCardExists = [deck moveToCardInDirection:NextCard includeKnownCards:NO];}
		else // _studyType == View
			{additionalCardExists = [deck moveToCardInDirection:NextCard includeKnownCards:YES];}
		if (additionalCardExists == YES) // if there's a card in this deck other than the one already displayed
		{
			[self showNewCardWithAnimation:CardViewAnimationSlideLeft];
		}				
		processedCurrentSwipe = YES;
	}
}

-(void)processUpSwipe
{
	// no action
}

-(void)processDownSwipe
{
	// no action 
}

-(void)processSingleTap
{
	if (searchBar.isFirstResponder)
	{
		[searchBar resignFirstResponder];
	}	
	else
	{
		int oldSide = deck.getCurrentSideID;
		BOOL nextSideExists = [deck nextSide]; // update deck pointer to next side
		if ((nextSideExists) == YES) // if there is a next side (i.e. current side has successfully updated)
		{
			// load old side onto top card & new side onto bottom card
			[topCardViewController loadBackSideWithDBSideID:oldSide];
			[bottomCardViewController loadBackSideWithDBSideID:deck.getCurrentSideID];
			// turn over both cards
			[topCardViewController revealHiddenSide:CardViewAnimationReveal];
			[bottomCardViewController revealHiddenSide:CardViewAnimationReveal];	
		}
	}
}

-(void)processDoubleTap
{
	// no action
}


// ----- TOUCH METHODS -----

// When touch begins, store its start point
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	gestureStartPoint = [touch locationInView:self.view];
}

// When touch moves, check for swipe completion
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint currentPoint = [touch locationInView:self.view];
	
	CGFloat deltaX = gestureStartPoint.x - currentPoint.x;
	CGFloat deltaY = gestureStartPoint.y - currentPoint.y;
	
	if ((deltaX >= kMinimumGestureLength) && (fabsf(deltaY/deltaX) <= kMaximumVariance)) {
		// process right swipe
		[self processLeftSwipe];
	}
	
	if ((deltaX <= (kMinimumGestureLength*-1)) && (fabsf(deltaY/deltaX) <= kMaximumVariance)) {
		// process left swipe
		[self processRightSwipe];
	}	
	
	if ((deltaY >= (kMinimumGestureLength)) && (fabsf(deltaX/deltaY) <= kMaximumVariance)) {
		// process up swipe
		[self processUpSwipe];
	}

	if ((deltaY <= (kMinimumGestureLength*-1)) && (fabsf(deltaX/deltaY) <= kMaximumVariance)) {
		// process down swipe
		[self processDownSwipe];
	}
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// check for single tap
	if (([[touches anyObject] tapCount] == 1) && (processedCurrentSwipe == NO)) // If was a single tap and not a swipe
	{
		[self processSingleTap];
	}
	
	// check for double tap
	if (([[touches anyObject] tapCount] == 2) && (processedCurrentSwipe == NO)) // If was a double tap and not a swipe
	{
		[self processDoubleTap];
	}
	
	// set flag to recognise future touches as a new gesture
	processedCurrentSwipe = NO;
}


// ---- ACTION METHODS ------

- (IBAction)bottomButtonClicked:(id)sender
{
	if (_studyType == Test)
	{
		// log card completed
			cardsCompleted = cardsCompleted + 1;
		
		// update known status & tick colours
			if (sender == tickButton) // tick was pressed
			{
				// set card to known; increment score
				[deck setCurrentCardKnown:YES];
				cardsCorrect++;
				
				// set tick to green, cross to white
				//[tickButton setImage:[UIImage imageNamed:@"GreenTick.png"] forState:UIControlStateNormal];
				//[crossButton setImage:[UIImage imageNamed:@"WhiteCross.png"] forState:UIControlStateNormal];
			}
			else // cross was pressed
			{
				// set card to unknown
				[deck setCurrentCardKnown:NO];
				
				//set cross to red, tick to white
				//[crossButton setImage:[UIImage imageNamed:@"RedCross.png"] forState:UIControlStateNormal];		
				//[tickButton setImage:[UIImage imageNamed:@"WhiteTick.png"] forState:UIControlStateNormal];		
			}
		
		// update score display
			[self updateInlineScore];
		
		// move to next card or show finish screen
			if (cardsCompleted == numCards) // if all cards have been tested
			{
				// Push the FinalScoreViewController onto the navigation stack
					FinalScoreViewController *finalScoreViewController = [FinalScoreViewController sharedInstance];
					// set the scores
					float percent = ((float)cardsCorrect / (float)cardsCompleted) * 100.0;
					finalScoreViewController.percent = (int)percent; // 100% is only awarded if all Qs answered correctly (int cast appears to round down)
					finalScoreViewController.incorrectScore = cardsCompleted - cardsCorrect;
					finalScoreViewController.correctScore = cardsCorrect;
					// push to stack
					[self.navigationController pushViewController:finalScoreViewController animated:YES];
			}
			else // move to the next card
			{
				BOOL additionalCardExists = [deck moveToCardInDirection:NextCard includeKnownCards:YES];
				if (additionalCardExists == YES) // if there's a card in this deck other than the one already displayed
				{
					[self showNewCardWithAnimation:CardViewAnimationSlideLeft];
				}
			}
	}
	else // study type is Learn
	{
		// set card to known; increment score
		[deck setCurrentCardKnown:YES];
		cardsKnown++;
		
		// set tick to green
		[tickButton setImage:[UIImage imageNamed:@"GreenTick.png"] forState:UIControlStateNormal];
		
		// update score display
		[self updateInlineScore];
		
		if (cardsKnown == numCards) // if all cards have been tested
		{
			// Push the CongratulationsViewController onto the navigation stack
				CongratulationsViewController *congratulationsViewController = [CongratulationsViewController sharedInstance];
				// set the scores
				congratulationsViewController.totalCards = numCards;
				// push to stack
				[self.navigationController pushViewController:congratulationsViewController animated:YES];
		}
		
		
	}
}


-(void)updateInlineScore
{
	if (_studyType == Learn)
	{
		// top label
		[[inlineScoreViewController topMultipartLabel]  updateNumberOfLabels:2 fontSize:13 alignment:MultipartLabelRight];
		[[inlineScoreViewController topMultipartLabel] setText:@"Unknown:  " andColor:[UIColor whiteColor] forLabel:0];
		[[inlineScoreViewController topMultipartLabel] setText:[NSString stringWithFormat: @"%d", numCards - cardsKnown] andColor:[UIColor whiteColor] forLabel:1];
		
		[[inlineScoreViewController bottomMultipartLabel]  updateNumberOfLabels:2 fontSize:13 alignment:MultipartLabelRight];
		[[inlineScoreViewController bottomMultipartLabel] setText:@"Known:  " andColor:[UIColor whiteColor] forLabel:0];
		[[inlineScoreViewController bottomMultipartLabel] setText:[NSString stringWithFormat: @"%d", cardsKnown] andColor:[UIColor whiteColor] forLabel:1];		
	}
	else if (_studyType == Test)
	{
		// top label
		[[inlineScoreViewController topMultipartLabel]  updateNumberOfLabels:3 fontSize:13 alignment:MultipartLabelRight];
		[[inlineScoreViewController topMultipartLabel] setText:[NSString stringWithFormat: @"%d", cardsCompleted - cardsCorrect] andColor:[[VariableStore sharedInstance] mindeggRed] forLabel:0];
		[[inlineScoreViewController topMultipartLabel] setText:@" | " andColor:[UIColor whiteColor] forLabel:1];
		[[inlineScoreViewController topMultipartLabel] setText:[NSString stringWithFormat: @"%d", cardsCorrect] andColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:2];
		
		// bottom label
		[[inlineScoreViewController bottomMultipartLabel]  updateNumberOfLabels:1 fontSize:13 alignment:MultipartLabelRight];
		[[inlineScoreViewController bottomMultipartLabel] setText:[NSString stringWithFormat: @"%d left", numCards - cardsCompleted] andColor:[UIColor whiteColor] forLabel:0];
	}
	else // _studyType == View
	{
		[[inlineScoreViewController topMultipartLabel]  updateNumberOfLabels:0 fontSize:13 alignment:MultipartLabelRight];
		[[inlineScoreViewController bottomMultipartLabel]  updateNumberOfLabels:0 fontSize:13 alignment:MultipartLabelRight];
	}
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)sender
{
	// TO IMPLEMENT
}


/* SEARCH BAR ANIMATIONS DESCOPED

-(IBAction)showSearchBar:(id)sender
{	
	
	[UIView beginAnimations:@"searchBarIn" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	searchBarView.center = CGPointMake(160, 22);
	[UIView commitAnimations];
	
	[searchBar becomeFirstResponder];
}
 

-(void)hideSearchBar
{
	
	[UIView beginAnimations:@"searchBarOut" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// Move the rectangle to the location of the touch
	searchBarView.center = CGPointMake(160, -22);
	[UIView commitAnimations];
	
	[searchBar resignFirstResponder];

}
*/

// ---- MEMORY HANDLING METHODS -----

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[topCardViewController release];
	[bottomCardViewController release];
	[inlineScoreViewController release];
	[deck release];
    [super dealloc];
}

@end
