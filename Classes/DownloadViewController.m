//
//  AllDecksViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewController.h"
#import "VariableStore.h"
#import "DeckParser.h"
#import "ProgressViewController.h"

@implementation DownloadViewController

@synthesize database;

- (void)viewDidLoad {

	// set up background color
	//UIColor *color = [[VariableStore sharedInstance] backgroundColor];
	//super.view.backgroundColor = color;
	
	[idTextField	becomeFirstResponder];
	
    [super viewDidLoad];	
}

- (IBAction) downloadButtonClicked:(id)sender
{
	if (!(idTextField.text.length >= 8)) // if the user's not supplied a sensible ID, reject the request
	{
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:  [NSString stringWithFormat:@"Invalid Deck ID"]
								   message: [NSString stringWithFormat:@"Deck ID's should be at least 8 digits long."]
								   delegate: nil
								   cancelButtonTitle: @"OK"
								   otherButtonTitles: nil];
		[errorAlert show];
		[errorAlert release];
	}
	else // otherwise, get the requested deck
	{			
		// get the deck
		DeckParser *deckParser = [[DeckParser alloc] init];
		[deckParser getDeckWithUserDeckID:[idTextField.text integerValue] intoDB:database];
	}
	
	// go back to the library screen
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}

@end
