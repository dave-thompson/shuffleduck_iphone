//
//  CardViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

// Controls a single card within study mode
//
// To display a new card, call loadFrontSideWithDBSideID:(int)sideID or loadFrontSideBlank.
// To display a new side of a card, call loadBackSideWithDBSideID:(int)sideID or loadBackSideBlank, each followed by flipCard.


#import "CardViewController.h"


@implementation CardViewController

@synthesize sideAViewController, sideBViewController;
@synthesize DBDeckID, animationInProgress;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// setup side view controllers
	sideAViewController = [[SideViewController alloc] initWithNibName:@"SideView" bundle:nil];
	sideAViewController.view.frame = CGRectMake(0, 0, 260, 160);
	sideAViewController.view.clipsToBounds = YES;
	[self.view addSubview:sideAViewController.view];
	
	sideBViewController = [[SideViewController alloc] initWithNibName:@"SideView" bundle:nil];
	sideBViewController.view.frame = CGRectMake(0, 0, 260, 160);
	sideBViewController.view.clipsToBounds = YES;
	
	animationInProgress = NO;
}

// Method to transition shown card side to hidden card side. Specify animationStyle according to typedef above.
	// Each card shown on screen has a visible side and a hidden side. To turn over cards, move to a new card, or 
	// show a blank side, first set the hidden side using loadBackSideWithDBSideID or setBackSideBlank. Subsequently
	// call revealHiddenSide with the appropriate animationStyle for the type of card transition (new card, new side, etc.).
-(void)revealHiddenSide:(CardViewAnimation)animationStyle
{
	animationInProgress = YES;
	
	// Animation for revealing a new side
	if ((animationStyle == CardViewAnimationReveal) || (animationStyle == CardViewAnimationFlip))
	{
		// Start animation and set defaults
		[UIView beginAnimations:@"Card Turn" context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		
		// Set animation style specific properties
		if (animationStyle == CardViewAnimationReveal)
		{[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];}
		
		if (animationStyle == CardViewAnimationFlip)
		{[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];}

		// Switch views
		if (sideAViewController.view.superview == nil)
		{				
			[sideBViewController.view removeFromSuperview];
			[self.view insertSubview:sideAViewController.view atIndex:0];
		}
		else
		{
			[sideAViewController.view removeFromSuperview];
			[self.view insertSubview:sideBViewController.view atIndex:0];
		}

		[UIView commitAnimations];
	}
		
	// Animation for sliding in or out a new card
		// Add hidden view to frame, offset to right. Then slide both views left until the hidden view is shown.
		// Finally, remove the old side view from the superview.
	if ((animationStyle == CardViewAnimationSlideLeft) || (animationStyle == CardViewAnimationSlideRight))
	{
		UIView *hiddenView, *visibleView;
		// check which view is hidden and which is visible
		if (sideAViewController.view.superview == nil)
		{
			hiddenView = sideAViewController.view;
			visibleView = sideBViewController.view;
		}
		else
		{
			hiddenView = sideBViewController.view;
			visibleView = sideAViewController.view;
		}
		
		// add hidden side view to card view
		[self.view insertSubview:hiddenView atIndex:0];
		
		if (animationStyle == CardViewAnimationSlideLeft)
			// position hidden view just off screen to right
			{hiddenView.center = CGPointMake(420,80);}
		else // is a slide right
			// position hidden view just off screen to left
			{hiddenView.center = CGPointMake(-160,80);}
		
		// Start animation and set defaults
		[UIView beginAnimations:@"Card Slide" context:visibleView];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		
		// move hidden view to middle and visible view to outside
		hiddenView.center = CGPointMake(130,80);
		
		if (animationStyle == CardViewAnimationSlideLeft)
			// position hidden view just off screen to right
		{visibleView.center = CGPointMake(-160,80);}
		else // is a slide right
			// position visible view just off screen to left
		{visibleView.center = CGPointMake(420,80);}
		
		[UIView commitAnimations];
	}	
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(UIView *)visibleView
{
	if (animationID == @"Card Slide")
	{
		visibleView.center = CGPointMake(130,80);
		[visibleView removeFromSuperview];
		animationInProgress = NO;
	}

	if (animationID == @"Card Turn")
	{
		animationInProgress = NO;
	}
	

}

-(void)loadFrontSideWithDBSideID:(int)sideID
{
	if (sideAViewController.view.superview == nil) // side A is the back side
	{	
		// load side B from the DB
		[sideBViewController replaceSideWithSideID:sideID];
	}
	else
	{
		// load side A from the DB
		[sideAViewController replaceSideWithSideID:sideID];

	}
}

-(void)loadBackSideWithDBSideID:(int)sideID
{
	if (sideAViewController.view.superview == nil) // side A is the back side
	{	
		// load side A from the DB
		[sideAViewController replaceSideWithSideID:sideID];
	}
	else
	{
		// load side B from the DB
		[sideBViewController replaceSideWithSideID:sideID];
	}
	
}

-(void)setBackSideBlank
{
	if (sideAViewController.view.superview == nil) // side A is the back side
	{	
		// set side A to be blank
		[sideAViewController	clearSide];
	}
	else
	{
		// set side B to be blank
		[sideBViewController	clearSide];
	}
	
}

-(void)setFrontSideBlank
{
	if (sideAViewController.view.superview == nil) // side A is the back side
	{	
		// set side B to be blank
		[sideBViewController	clearSide];
	}	
	else
	{
		// set side A to be blank
		[sideAViewController	clearSide];
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[sideAViewController release];
	[sideBViewController release];
    [super dealloc];
}


@end
