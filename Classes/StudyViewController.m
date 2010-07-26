//
//  StudyViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "StudyViewController.h"
#import "SideViewController.h"
#import "CardViewController.h"
#import "InlineScoreViewController.h"
#import "ContinueTestViewController.h"
#import "VariableStore.h"
#import "FinalScoreViewController.h"
#import "CongratulationsViewController.h"
#import "Constants.h"
#import "TutorialViewController.h"

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

// Type management
StudyType _studyType = Test; // xib is initially set up for Test
StudyType _requestedStudyType;

// Score tracking

	// Study / View
	int numCards;
		// Study
		int cardsKnown = 0;
		// View
		int numFilteredCards = 0;

	// Test
	int cardsCompleted = 0;
	int cardsCorrect = 0;
	int cardsInTestSet = 0;


BOOL searchTextExists; // whether there was any text in the search bar after text was last edited
BOOL cardHidden = NO; // whether the card is shown or not

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
		
	// set up search bar
		// reposition on top of cards
		[searchBarView retain];
		[searchBarView removeFromSuperview];
		[self.view insertSubview:searchBarView atIndex:2];
		[searchBarView release];
	
		// do not 'fix' input text
		searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
		searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	 
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
	
	// reconfigure screen components to suit StudyType
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
	
	// Point deck at appropriate card, dependent on StudyType
	[deck moveToLastSessionsCardForStudyType:_studyType];

	// for View, also populate search bar with text from last time
	if (_studyType == View)
	{
		searchBar.text = deck.searchBarText;
		if (searchBar.text.length > 0)
		{
			searchTextExists = YES;
		}
		else
		{
			searchTextExists = NO;
		}
		numFilteredCards = [deck numCardsWithSearchTerm:searchBar.text];
	}
	
	// for Test, set up scores
	if (_studyType == Test)
	{
		cardsCompleted = deck.cardsCompleted;
		cardsCorrect = deck.cardsCorrect;
		cardsInTestSet = deck.cardsInTestSet;
	}
	
	// show the selected card
	if (_studyType == Learn || _studyType == Test)
	{
		[self showNewCard];
	}
	else // _studyType == View
	{
		if (numFilteredCards > 0)
			[self showNewCard];
		else
			[self hideCard];
	}
	
	// if in Study or Test mode, check to see how many sides should be showing
	if ((_studyType == Learn) || (_studyType == Test))
	{
		int sideIDToShow = [deck lastSessionsSideIDForStudyType:_studyType];
		// sideIDToShow is either - -1, meaning that there was no previous session for this deck
		//                     or - a side of a card which is no longer the first card shown
		//					   or - one of the sides of the shown card
		
		// if this deck has been studied in Learn mode before
		//    and the side that was last revealed in Learn mode is a side from the current card
		//    and the side that was last revealed in Learn mode is NOT the current side
		//    .... then show the next side
		if ((sideIDToShow >= 0) && ([deck doesCurrentCardContainSideID:sideIDToShow]) && (deck.currentSideID != sideIDToShow))
		{
			[self showNextSide];
		}
	}

	// update the score panel
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
		if ((!(vc == [FinalScoreViewController sharedInstance])) && (!(vc == [CongratulationsViewController sharedInstance])) && (!(vc == [ContinueTestViewController sharedInstance])) &&  (!(vc == [TutorialViewController sharedInstance])))
		{
			[newVCArray addObject:vc];
		}
	}
	[self navigationController].viewControllers = newVCArray;
	[newVCArray release];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// dismiss the keyboard
	if ([searchBar isFirstResponder])
	{
		[searchBar resignFirstResponder];
	}
	
	//remember the card currently viewed
	[deck rememberCardForStudyType:_studyType];

	// if there's a search bar, remember the text in it
	if (_studyType == View)
	{
		deck.searchBarText = searchBar.text;
	}
}

// setStudyType must be called before showing the view
// setStudyType does not have effect until viewWillAppear runs
-(void)setStudyType:(StudyType)studyType
{
	_requestedStudyType = studyType;
}

-(StudyType)getStudyType
{
	return _studyType;
}

// ----- LOGIC METHODS -----

-(void)showNewCard
// Display a new card
// Before calling this method, call deck.nextCard to increment the card pointer (unless the deck is new; Deck instantiation automatically points to the first card).
{	
	if (cardHidden)
	{
		[self.view addSubview:topCardViewController.view];
		[self.view addSubview:bottomCardViewController.view];	
		cardHidden = NO;
	}
	
	// Top Card: Display the current side of the current card
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

-(void)hideCard
{
	[topCardViewController.view removeFromSuperview];
	[bottomCardViewController.view removeFromSuperview];
	cardHidden = YES;
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
			{
				BOOL dismissedCardWasKnown = [deck isCurrentCardKnown];
				if (dismissedCardWasKnown)
				{
					// replace the dismissed card in the study session with a new card, and point to this new card
					// thus the user will be presented with the new card straight away (they are going backwards through their cards)
					[deck replaceCardInStudySessionAtIndex:0];
					[deck pointToUsersStudySession];
					additionalCardExists = ([deck numCardsInStudySession] > 0);
				}
				else
				{
					// move to the previous card
					additionalCardExists = [deck moveToPreviousCardInStudySession];
				}
			}
		else // _studyType == View
			{
				additionalCardExists = [deck moveToCardInDirection:PreviousCard withSearchTerm:[searchBar text]];
			}
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
			{
				BOOL dismissedCardWasKnown = [deck isCurrentCardKnown];
				additionalCardExists = [deck moveToNextCardInStudySession];
				if (dismissedCardWasKnown)
				{
					// the user will be presented with the new card only once they have gone through all the older cards in their hands again first
					[deck replaceLastCardInStudySession];
				}
			}
		else // _studyType == View
			{
				additionalCardExists = [deck moveToCardInDirection:NextCard withSearchTerm:[searchBar text]];
			}
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
		[self showNextSide];
	}
}

-(void)showNextSide
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
	// only process button clicks if there is a stable card being shown
	if ((topCardViewController.animationInProgress == NO) && (bottomCardViewController.animationInProgress == NO))
	{
		if (_studyType == Test)
		{
			// log card completed
				cardsCompleted = cardsCompleted + 1;
			
			// update known status & tick colours
				if (sender == tickButton) // tick was pressed
				{
					// update test & card data; increment score
					[deck setTestQuestionCorrect:YES];
					cardsCorrect++;
				}
				else // cross was pressed
				{
					// update test & card data; increment score
					[deck setTestQuestionCorrect:NO];
				}
			
			// update score display
				[self updateInlineScore];
			
			// move to next card or show finish screen
				if (cardsCompleted == numCards) // if all cards have been tested
				{
					// Push the FinalScoreViewController onto the navigation stack
					[self pushFinalScoreViewControllerAsPartofApplicationLoadProcess:NO];
				}
				else // move to the next card
				{
					BOOL additionalCardExists = [deck moveToFirstUnansweredTestQuestion];
					if (additionalCardExists == YES) // if there's a card in this deck other than the one already displayed
					{
						[self showNewCardWithAnimation:CardViewAnimationSlideLeft];
					}
				}
		}
		else // study type is Learn
		{
			if ([deck isCurrentCardKnown])
			{
				// set card to unknown; decrement score
				[deck setCurrentCardKnown:NO];
				cardsKnown--;
				
				// set tick to white
				[tickButton setImage:[UIImage imageNamed:@"WhiteTick.png"] forState:UIControlStateNormal];			
			}
			else
			{
				// set card to known; increment score
				[deck setCurrentCardKnown:YES];
				cardsKnown++;
				
				// set tick to green
				[tickButton setImage:[UIImage imageNamed:@"GreenTick.png"] forState:UIControlStateNormal];
			}
			
			// update score display
			[self updateInlineScore];
			
			if (cardsKnown == numCards) // if all cards have been tested
			{
				// remove the final card from the study session
				[deck replaceLastCardInStudySession];
				
				// Push the CongratulationsViewController onto the navigation stack
				[self pushCongratulationsViewControllerAsPartofApplicationLoadProcess:NO];
			}
		}
	}
}

-(void)pushCongratulationsViewControllerAsPartofApplicationLoadProcess:(BOOL)partOfLoadProcess
{
	CongratulationsViewController *congratulationsViewController = [CongratulationsViewController sharedInstance];
	// set the scores
	congratulationsViewController.totalCards = deck.numCards;
	// push to stack
	if (partOfLoadProcess)
	{
		// set up back button (viewDidLoad will not have fired yet)
		UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
		self.navigationItem.backBarButtonItem = backArrowButton;
		[backArrowButton release];	
		// push view controller		
		[self.navigationController pushViewController:congratulationsViewController animated:NO];
	}
	else
		[self.navigationController pushViewController:congratulationsViewController animated:YES];	
}

-(void)pushFinalScoreViewControllerAsPartofApplicationLoadProcess:(BOOL)partOfLoadProcess
{
	FinalScoreViewController *finalScoreViewController = [FinalScoreViewController sharedInstance];
	finalScoreViewController.deck = deck;		

	if (partOfLoadProcess)
	{
		// set up back button (viewDidLoad will not have fired yet)
		UIBarButtonItem *backArrowButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackArrow.png"] style:UIBarButtonItemStyleDone target:nil action:nil]; 
		self.navigationItem.backBarButtonItem = backArrowButton;
		[backArrowButton release];
				
		// push view controller
		[self.navigationController pushViewController:finalScoreViewController animated:NO];
	}
	else
	{		
		// push view controller
		[self.navigationController pushViewController:finalScoreViewController animated:YES];
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
		[[inlineScoreViewController bottomMultipartLabel] setText:[NSString stringWithFormat: @"%d left", cardsInTestSet - cardsCompleted] andColor:[UIColor whiteColor] forLabel:0];
	}
	else // _studyType == View
	{
		if (searchBar.text.length == 0)
		{
			[[inlineScoreViewController topMultipartLabel]  updateNumberOfLabels:0 fontSize:13 alignment:MultipartLabelRight];
			[[inlineScoreViewController bottomMultipartLabel]  updateNumberOfLabels:1 fontSize:13 alignment:MultipartLabelRight];
			[[inlineScoreViewController bottomMultipartLabel] setText:[NSString stringWithFormat: @"%d cards", numCards] andColor:[UIColor whiteColor] forLabel:0];
		}
		else
		{
			[[inlineScoreViewController topMultipartLabel]  updateNumberOfLabels:1 fontSize:13 alignment:MultipartLabelRight];
			[[inlineScoreViewController topMultipartLabel] setText:[NSString stringWithFormat: @"%d matches", numFilteredCards] andColor:[UIColor whiteColor] forLabel:0];
			[[inlineScoreViewController bottomMultipartLabel]  updateNumberOfLabels:1 fontSize:13 alignment:MultipartLabelRight];
			[[inlineScoreViewController bottomMultipartLabel] setText:[NSString stringWithFormat: @"%d cards", numCards] andColor:[UIColor whiteColor] forLabel:0];
		}
		
	}
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)sender
{
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
	// Update number of cards found
		numFilteredCards = [deck numCardsWithSearchTerm:searchText];
		[self updateInlineScore];
	
	if (numFilteredCards > 0)
	{
	// Do search
		NSString *searchTerm = [searchBar text];
		// if the new filter invalidates the currently shown card (or there is no currently shown card), replace it with the first card that matches the new filter
		if ((![deck currentCardFitsFilter:searchText]) || (cardHidden))
		{
			[deck moveToCardAtPosition:FirstCard withSearchTerm:searchTerm];
			[self showNewCard];
		}
	}
	else
	{
		[self hideCard];
	}
	
	// Logic for searchBarShouldBeginEditing method
		// remember whether the edit left the search bar with any text in or not
		if ([searchBar isFirstResponder])
		// only handle changes that occur when the search bar is in edit mode (this excludes only changes arising when the user clicks x on the search bar when it is not in edit mode - such changes are handled by searchBarShoudBeginEditing below)
		{
			if (searchText.length == 0)
			{
				searchTextExists = NO;
			}
			else
			{
				searchTextExists = YES;
			}
		}		
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
	// if the search bar had text in it the last time the keyboard was present, but does not have text in it now....
	// ... it is because the user just pressed the x button while the keyboard was not present
	// .. therefore do not start editing text
	if (searchTextExists && (searchBar.text.length == 0))
	{
		searchTextExists = NO; // search text no longer exists - the next time the user presses on the search bar, it should begin editing, even though no text exists in it
		return NO;
	}
	else
	{
		return YES;
	}
}

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
