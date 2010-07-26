//
//  TableFooterViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableFooterViewController.h"


@implementation TableFooterViewController

UIImageView *imageView;

@synthesize label;

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
	[label release];
    [super dealloc];
}


@end
