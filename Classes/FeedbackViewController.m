//
//  FeedbackViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"
#import "VariableStore.h"
#import "ShuffleDuckUtilities.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Constants.h"
#import "ProgressViewController.h"

static FeedbackViewController *sharedFeedbackViewController = nil;

@implementation FeedbackViewController

// manage the shared instance of this singleton View Controller
+ (FeedbackViewController *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedFeedbackViewController)
		{
			sharedFeedbackViewController = [[[self class] alloc] initWithNibName:@"FeedbackView" bundle:nil];
		}
	}
    return sharedFeedbackViewController;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	// create placeholder text
	messageTextView.placeholder = @"Message";
	emailTextView.placeholder = @"Email (optional)";
	
	// setup send button
	UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButtonPressed:)];
	self.navigationItem.rightBarButtonItem = sendButton;
	[sendButton release];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// populate text fields with any data the user put in there before
	NSString *feedback_message;
	NSString *feedback_email;
	NSString *sqlString = @"SELECT feedback_message, feedback_email FROM ApplicationStatus;";
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			feedback_message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
			feedback_email = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	messageTextView.text = [feedback_message stringByReplacingOccurrencesOfString:@"''" withString:@"''"];
	emailTextView.text = [feedback_email stringByReplacingOccurrencesOfString:@"''" withString:@"''"];
	
	// put the cursor in the message text box and show the keyboard
	[messageTextView becomeFirstResponder];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	// remember the text that the user put in the text views
	NSString *feedback_message = [messageTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	NSString *feedback_email = [emailTextView.text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];;		
	[ShuffleDuckUtilities runSQLUpdate:[NSString stringWithFormat:@"UPDATE ApplicationStatus SET feedback_message = '%@', feedback_email = '%@';", feedback_message, feedback_email]];
}

-(void)sendButtonPressed:(id)sender
{
	[ProgressViewController startShowingProgress];
	
	// build POST data	
	NSString *email = [[@"<email>" stringByAppendingString:emailTextView.text] stringByAppendingString:@"</email>"];
	NSString *message = [[@"<message>" stringByAppendingString:messageTextView.text] stringByAppendingString:@"</message>"];
	NSString *postData = [[[@"<feedback>" stringByAppendingString:email]stringByAppendingString:message] stringByAppendingString:@"</feedback>"];
	
	// POST request
	NSString *urlParameters = [ShuffleDuckUtilities buildRequestParameters:postData];
	NSURL *url = [NSURL URLWithString:[[CONTEXT_URL stringByAppendingString:@"/feedbacks"] stringByAppendingString:urlParameters]]
	;
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request appendPostData:[postData dataUsingEncoding:NSUTF8StringEncoding]];
	[request addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"application/xml"]];
	[request setDidFinishSelector:@selector(postFinished:)];
	[request setDidFailSelector:@selector(postFailed:)];
	[request startAsynchronous];
}

-(void)postFinished:(ASIHTTPRequest *)request
{
	[ProgressViewController stopShowingProgress];
	
 	UIAlertView *alert = [[UIAlertView alloc]
							   initWithTitle:  [NSString stringWithFormat:@"Thanks"]
							   message: [NSString stringWithFormat:@"We received your feedback."]
							   delegate: nil
							   cancelButtonTitle: @"OK"
							   otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	messageTextView.text = @"";
	emailTextView.text = @"";
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)postFailed:(ASIHTTPRequest *)request
{
	[ProgressViewController stopShowingProgress];
	
 	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle:  [NSString stringWithFormat:@"Couldn't reach ShuffleDuck"]
							   message: [NSString stringWithFormat:@"Please check your network connection and try again."]
							   delegate: nil
							   cancelButtonTitle: @"OK"
							   otherButtonTitles: nil];
	[errorAlert show];
	[errorAlert release];
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
