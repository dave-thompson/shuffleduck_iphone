//
//  TableFooterViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableFooterViewController.h"


@implementation TableFooterViewController

UIImageView *imageView;

@synthesize label;

/*
// Call this if the table has no content
// Sets the table footer to an image asking the user to put something in the table
- (void)showContentlessImage
{
	// resize footer & remove label
	self.view.bounds = CGRectMake(0, 0, 320, 367);
	label.text = @"";
	
	// add image
	imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoContent.png"]];
	imageView.frame = CGRectMake(0,0,320,367);
	imageView.contentMode = UIViewContentModeTop;
	[self.view addSubview:imageView];
}


// Call this if there is > 0 decks in the table
// Must set label text manually after doing so
- (void)showTableContent
{
	// resize footer and remove image
	self.view.bounds = CGRectMake(0, 0, 320, 40);
	[imageView removeFromSuperview];
	[imageView release];
	imageView = nil;
}
*/


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
