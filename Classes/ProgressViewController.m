//
//  ProgressViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProgressViewController.h"
#import "MindEggAppDelegate.h"

static BOOL showing = NO;

@implementation ProgressViewController

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

+ (void)startShowingProgress
{
	// If progress not currently shown, show it
	if (!(showing))
	{
		MindEggAppDelegate *appDelegate = (MindEggAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate window] addSubview:[[ProgressViewController sharedInstance] view]];
	}
	showing = YES;
}

+ (void)stopShowingProgress
{
	[[ProgressViewController sharedInstance].view removeFromSuperview];
	showing = NO;
}

+ (void)refresh
{
	if (showing) // move the progress view controller to the top of the view stack UIViewController
	{
		MindEggAppDelegate *appDelegate = (MindEggAppDelegate *)[[UIApplication sharedApplication] delegate];
		[[appDelegate window] bringSubviewToFront:[ProgressViewController sharedInstance].view];
	}	
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//[activityIndicator startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	//[activityIndicator stopAnimating];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
