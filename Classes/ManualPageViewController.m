//
//  ManualPageViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ManualPageViewController.h"


@implementation ManualPageViewController

@synthesize webView, urlString;

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
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
	[webView release];
	[urlString release];
}


@end
