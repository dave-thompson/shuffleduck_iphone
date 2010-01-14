//
//  StudyViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "StudyViewController.h"
#import "RandomColor.h"
#import "SideViewController.h"
#import "CardViewController.h"
#import "InlineScoreViewController.h"
#import "VariableStore.h"
#import "FinalScoreViewController.h"

@implementation StudyViewController

@synthesize deck, database;

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
	int numCards;

	// Study
	int cardsKnown;

	// Test
	int cardsCompleted;
	int cardsCorrect;

CardViewController *topCardViewController, *bottomCardViewController;
InlineScoreViewController *inlineScoreViewController;

// ----- INITIALISERS ------

- (void)viewDidLoad { // should this be in viewWillLoad?

	// initiate state data
			processedCurrentSwipe = NO;
			kMaximumVariance = tan(kMaximumVarianceInDegrees);
			numCards = deck.numCards;
			cardsKnown = deck.numKnownCards;
			cardsCompleted = 0;
			cardsCorrect = 0;
	
	/* SEARCH FUNCTIONALITY DESCOPED
	// setup search button
			UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MagnifyingGlass.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSearchBar:)]; 
			self.navigationItem.rightBarButtonItem = searchButton;
			[searchButton release];
	*/
	
	// setup Card Side subviews
			topCardViewController = [[CardViewController alloc] initWithNibName:@"SideView" bundle:nil];
			topCardViewController.view.frame = CGRectMake(30, 16, 260, 160);
			[self.view insertSubview:topCardViewController.view atIndex:4];
			topCardViewController.database = deck.database;
	
			bottomCardViewController = [[CardViewController alloc] initWithNibName:@"SideView" bundle:nil];
			bottomCardViewController.view.frame = CGRectMake(30, 192, 260, 160);
			[self.view insertSubview:bottomCardViewController.view atIndex:4];
			bottomCardViewController.database = deck.database;
	
	// Set up the inline score view
	inlineScoreViewController = [[InlineScoreViewController alloc] initWithNibName:@"InlineScoreView" bundle:nil];
	UIBarButtonItem *scoreBarButton = [[UIBarButtonItem alloc] initWithCustomView:inlineScoreViewController.view];
	self.navigationItem.rightBarButtonItem = scoreBarButton; 
	[scoreBarButton release];
	[self updateInlineScore];
	
	// set up StudyType specifics
			if (_studyType == Learn)
			{
				// remove the cross button & resize the tick button
				[crossButton removeFromSuperview];
				tickButton.frame = CGRectMake(0, 0, 320, 49);				
			}
			else // is a test
			{
				// do nothing
			}
	
	//load first side of first card (incoming deck object already set to first card)
			[self showNewCard];
	
	/* SEARCH BAR FUNCTIONALITY DESCOPED
	// reposition search bar on top of cards
			[searchBarView retain];
			[searchBarView removeFromSuperview];
			[self.view insertSubview:searchBarView atIndex:2];
			[searchBarView release];
	*/
	 
	// set background color
	UIColor *color = [[VariableStore sharedInstance] backgroundColor];
	outerView.backgroundColor = color;
	topCardViewController.view.backgroundColor = color;
	bottomCardViewController.view.backgroundColor = color;
	
	//[self setBackgroundColor];	
	
	//call super
	[super viewDidLoad];
}



/*
-(void)setBackgroundColor
{
	const char *sqlStatement = "SELECT red_color, blue_color, green_color FROM Setting;";
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		// should only be one row, so no real need for this loop
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			// Read the color data from the result row
			red = (CGFloat)sqlite3_column_double(compiledStatement, 0);
			blue = (CGFloat)sqlite3_column_double(compiledStatement, 1);
			green = (CGFloat)sqlite3_column_double(compiledStatement, 2);
		}
	}
	// Release the compiled statement from memory
	sqlite3_finalize(compiledStatement);
	
	UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	
	outerView.backgroundColor = color;
	topCardViewController.view.backgroundColor = color;
	bottomCardViewController.view.backgroundColor = color;
}
 */

-(void)setStudyType:(StudyType)studyType
{
	_studyType = studyType;
}

// ----- LOGIC METHODS -----

-(void)showNewCard
// Display a new card
// Before calling this method, call deck.nextCard to increment the card pointer (unless the deck is new; Deck instantiation automatically points to the first card).
{	
	// Top Card: Display the the current side of the current card
	[topCardViewController loadFrontSideWithDBSideID:deck.currentSideID];
	[topCardViewController setBackSideBlank];
	
	// Bottom card: Leave empty pending user action
	[bottomCardViewController setFrontSideBlank];
	[bottomCardViewController setBackSideBlank];
	
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
	[bottomCardViewController setBackSideBlank];
	
	// transition to hidden sides
	[topCardViewController revealHiddenSide:direction];
	[bottomCardViewController revealHiddenSide:direction];
	
	// Reset the bottom button colours
	if (_studyType == Learn)
	{
		[tickButton setImage:[UIImage imageNamed:@"WhiteTick.png"] forState:UIControlStateNormal];
		//[crossButton setImage:[UIImage imageNamed:@"WhiteCross.png"] forState:UIControlStateNormal];
	}
}

// ----- GESTURE METHODS -----

-(void)processRightSwipe
{
	// ignore swipes in Test mode
	if (_studyType == Learn)
	{
		if (processedCurrentSwipe == NO) // only process if not already done so
		{
			if ((topCardViewController.animationInProgress == NO) && (bottomCardViewController.animationInProgress == NO)) // ignore swipe if the last swipe animation hasn't finished
			{
				BOOL additionalCardExists = [deck moveToCardInDirection:PreviousCard includeKnownCards:NO];
				if (additionalCardExists == YES) // if there's a card in this deck other than the one already displayed
				{
					[self showNewCardWithAnimation:CardViewAnimationSlideRight];
				}
				processedCurrentSwipe = YES;
			}
		}
	}
}

-(void)processLeftSwipe
{
	// ignore swipes in Test mode
	if (_studyType == Learn)
	{
		if (processedCurrentSwipe == NO) // only process if not already done so
		{		
			if ((topCardViewController.animationInProgress == NO) && (bottomCardViewController.animationInProgress == NO)) // ignore swipe if the last swipe animation hasn't finished
			{
				BOOL additionalCardExists = [deck moveToCardInDirection:NextCard includeKnownCards:NO];
				if (additionalCardExists == YES) // if there's a card in this deck other than the one already displayed
				{
					[self showNewCardWithAnimation:CardViewAnimationSlideLeft];
				}				
				processedCurrentSwipe = YES;
			}
		}
	}
}

-(void)processUpSwipe
{
	/* COLOR CHANGE DISABLED
	// assign random color to background and store as state
	UIColor *randomColor = [RandomColor randomColorWithStateUpdate:(database)];
	outerView.backgroundColor = randomColor;
	topCardViewController.view.backgroundColor = randomColor;
	bottomCardViewController.view.backgroundColor = randomColor;
	 */
}

-(void)processDownSwipe
{
	[self processUpSwipe];
}

-(void)processSingleTap
{
	/* SEARCH FUNCTIONALITY DESCOPED
	if (searchBar.isFirstResponder) // if search bar is on then dismiss it
	{
		[self hideSearchBar];			
	}
	else // else show next side on current card
	{
	 */
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
	/*}*/
}

-(void)processDoubleTap
{
	// DOUBLE TAP TO BACK UP THROUGH CARD SIDES
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

- (IBAction)bottomButtonClicked:(id)sender;
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
				// Push a FinalScoreViewController onto the navigation stack
					// create view controller
					FinalScoreViewController *finalScoreViewController = [[FinalScoreViewController alloc] initWithNibName:@"FinalScoreView" bundle:nil];
					finalScoreViewController.title = @"";
					finalScoreViewController.hidesBottomBarWhenPushed = YES;
					// set the scores
					float percent = ((float)cardsCorrect / (float)cardsCompleted) * 100.0;
					finalScoreViewController.percent = (int)percent; // 100% is only awarded if all Qs answered correctly (int cast appears to round down)
					finalScoreViewController.potentialScore = cardsCompleted;
					finalScoreViewController.actualScore = cardsCorrect;
					// push to stack
					[self.navigationController pushViewController:finalScoreViewController animated:YES];
					[finalScoreViewController release];				
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
	}
}


-(void)updateInlineScore
{
	if (_studyType == Learn)
	{
		[inlineScoreViewController setTopLabelText:[NSString stringWithFormat: @"Known: %d", cardsKnown]];
		[inlineScoreViewController setBottomLabelText:[NSString stringWithFormat: @"Left:  %d", numCards - cardsKnown]];	
	}
	else // is a test
	{
		[inlineScoreViewController setTopLabelText:[NSString stringWithFormat: @"%d / %d", cardsCorrect, cardsCompleted]];
		[inlineScoreViewController setBottomLabelText:[NSString stringWithFormat: @"(%d left)", numCards - cardsCompleted]];
	}
}

/* SEARCH FUNCTIONALITY DESCOPED

- (void)searchBarSearchButtonClicked:(UISearchBar *)sender
{
	[self hideSearchBar];
}

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
