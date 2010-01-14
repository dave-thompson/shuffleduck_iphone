//
//  ProgressViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProgressViewController.h"
#import "MindEggAppDelegate.h"

// variable to count the number of current users of the progress view
static int numberOfOperationsInProgress = 0;

@implementation ProgressViewController

@synthesize activityIndicator, label;

+ (ProgressViewController *)sharedInstance
{
    // the instance of this class is stored here
    static ProgressViewController *myInstance = nil;
	
    // check to see if an instance already exists
    if (nil == myInstance)
	{
        myInstance  = [[[self class] alloc] init];
    }
    // return the instance of this class
    return myInstance;
}

// Starts showing progress unless it is already showing
// Also increments the count of objects using the progress screen
+ (void)startShowingProgress
{
	ProgressViewController *progressViewController = [ProgressViewController sharedInstance];
	
	// If progress not currently shown, show it
	if (numberOfOperationsInProgress == 0)
	{
		MindEggAppDelegate *appDelegate = (MindEggAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate window] addSubview:[progressViewController view]];
	}	
	
	// Keep count of how many operations have requested a progress indicator
    numberOfOperationsInProgress++;
	
	// Update label to show how many decks remain to be downloaded
	if (numberOfOperationsInProgress == 1)
	{
		progressViewController.label.text = [NSString stringWithFormat:@"Downloading 1 deck ..."];
	}
	else
	{
		progressViewController.label.text = [NSString stringWithFormat:@"Downloading %d decks ...", numberOfOperationsInProgress];
	}
	
}

// Decrements the count of objects using the progress screen
// If count reaches zero, removes the progress screen
+ (void)stopShowingProgress
{
	ProgressViewController *progressViewController = [ProgressViewController sharedInstance];

	// Keep count of how many operations have requested a progress indicator
	if (numberOfOperationsInProgress > 0)
	{
		numberOfOperationsInProgress--;
	}
	// Remove progress indicator if there is nothing remaining in progress
	if (numberOfOperationsInProgress == 0)
	{
		[progressViewController.view removeFromSuperview];
	}
	
	// Update label to show how many decks remain to be downloaded
	if (numberOfOperationsInProgress == 1)
	{
		progressViewController.label.text = [NSString stringWithFormat:@"Downloading 1 deck ..."];
	}
	else
	{
		progressViewController.label.text = [NSString stringWithFormat:@"Downloading %d decks ...", numberOfOperationsInProgress];
	}
	
}


- (void)viewWillAppear
{
	[activityIndicator startAnimating];
}

- (void)viewWillDisappear: (BOOL)animated
{
	[activityIndicator stopAnimating];
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
