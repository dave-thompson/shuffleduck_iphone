//
//  DonwloadViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewController.h"
#import "VariableStore.h"
#import "DeckDownloader.h"
#import "ProgressViewController.h"

static DownloadViewController *sharedDownloadViewController = nil;

@implementation DownloadViewController

// manage the shared instance of this singleton View Controller
+ (DownloadViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedDownloadViewController)
		{
			sharedDownloadViewController = [[[self class] alloc] initWithNibName:@"DownloadView" bundle:nil];
		}
	}
    return sharedDownloadViewController;
}

- (void)viewDidLoad {
	UIColor *color = [[VariableStore sharedInstance] backgroundColor];
	super.view.backgroundColor = color;
	super.title = @"Download";
    [super viewDidLoad];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[idTextField	becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	idTextField.text = @"";
}
- (IBAction) downloadButtonClicked:(id)sender
{
	if (!(idTextField.text.length >= 8)) // if the user's not supplied a sensible ID, reject the request
	{
		UIAlertView *errorAlert = [[UIAlertView alloc]
								   initWithTitle:  [NSString stringWithFormat:@"Invalid Deck ID"]
								   message: [NSString stringWithFormat:@"Please check it and try again."]
								   delegate: nil
								   cancelButtonTitle: @"OK"
								   otherButtonTitles: nil];
		[errorAlert show];
		[errorAlert release];
	}
	else // otherwise, create a DeckDownloader which will handle retrieval of the Deck
	{
		[[DeckDownloader sharedInstance] downloadDeckID:[idTextField.text integerValue]];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (int)deckID
{
	return [idTextField.text intValue];
}

- (void)setDeckID:(int)deckID
{
	idTextField.text = [NSString stringWithFormat:@"%d", deckID];
}

- (void)dealloc {
    [super dealloc];
}

@end
