//
//  ASIAuthenticationDialog.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//
//	Modified by Dave Thompson on 26/01/2010
//  Modifications copyright 2009 MindEgg Ltd. All rights reserved.

#import "ASIAuthenticationDialog.h"
#import "ASIHTTPRequest.h"

ASIAuthenticationDialog *sharedDialog = nil;
NSLock *dialogLock = nil;

@interface ASIAuthenticationDialog ()
- (void)show;
@end

@implementation ASIAuthenticationDialog

+ (void)initialize
{
	if (self == [ASIAuthenticationDialog class]) {
		dialogLock = [[NSLock alloc] init];
	}
}

+ (void)presentAuthenticationDialogForRequest:(ASIHTTPRequest *)request delegate:(id)aDelegate username:(NSString *)aUsername repeatAttempt:(BOOL)aRepeatAttempt
{
	[dialogLock lock];
	[sharedDialog release];
	sharedDialog = [[self alloc] init];
	[sharedDialog setRequest:request];
	sharedDialog.delegate = aDelegate;
	sharedDialog.username = aUsername;
	sharedDialog.repeatAttempt = aRepeatAttempt;
	[sharedDialog show];
	[dialogLock unlock];
}

- (void)show
{
	// Create an action sheet to show the login dialog
	[self setLoginDialog:[[[UIActionSheet alloc] init] autorelease]];
	[[self loginDialog] setActionSheetStyle:UIActionSheetStyleBlackOpaque];
	[[self loginDialog] setDelegate:self];
	
	// We show the login form in a table view, similar to Safari's authentication dialog
	UITableView *table = [[[UITableView alloc] initWithFrame:CGRectMake(0,80,320,480) style:UITableViewStyleGrouped] autorelease];
	[table setDelegate:self];
	[table setDataSource:self];
	[[self loginDialog] addSubview:table];
	[[self loginDialog] showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:0]];
	[[self loginDialog] setFrame:CGRectMake(0,0,320,480)];
	
	// Setup the title (Couldn't figure out how to put this in the same toolbar as the buttons)
	UIToolbar *titleBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,30)] autorelease];
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10,0,300,30)] autorelease];
	[label setBackgroundColor:nil];
	[label setFont:[UIFont systemFontOfSize:13.0]];
	[label setShadowOffset:CGSizeMake(0, 1.0)];
	[label setOpaque:NO];
	[label setTextAlignment:UITextAlignmentCenter];
	if (repeatAttempt)
	{
		[titleBar setTintColor: [UIColor redColor]];
		[label setTextColor:[UIColor whiteColor]];
		[label setText:@"Couldn't log you on. Please try again."];
		[label setShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0]];
	}
	else
	{
		[label setTextColor:[UIColor blackColor]];
		[label setText:@"Go to mindegg.com to create cards."];
		[label setShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
	}
	
	[titleBar addSubview:label];
	[[self loginDialog] addSubview:titleBar];
	
	// Setup the toolbar 
	UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0,30,320,50)] autorelease];

	NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
	UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)] autorelease];
	[items addObject:backButton];
	
	label = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,170,50)] autorelease];
	[label setText:@"mindegg.com"];
	[label setTextColor:[UIColor whiteColor]];
	[label setFont:[UIFont boldSystemFontOfSize:22.0]];
	[label setShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
	[label setShadowOffset:CGSizeMake(0, -1.0)];
	[label setOpaque:NO];
	[label setBackgroundColor:nil];
	[label setTextAlignment:UITextAlignmentCenter];
	
	[toolbar addSubview:label];

	UIBarButtonItem *labelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil] autorelease];
	[labelButton setCustomView:label];
	[items addObject:labelButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonPressed:)] autorelease]];
	[toolbar setItems:items];
	
	[[self loginDialog] addSubview:toolbar];
	
	// Force reload the table content, and focus the first field to show the keyboard
	[table reloadData];
	[[[[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] subviews] objectAtIndex:2] becomeFirstResponder];
	
}

- (void)cancelButtonPressed:(id)sender
{
	[[self loginDialog] dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)loginButtonPressed:(id)sender
{
	// save entered credentials to the keychain
	NSString *user = [[[[[[[self loginDialog] subviews] objectAtIndex:0] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] subviews] objectAtIndex:2] text];
	NSString *password = [[[[[[[self loginDialog] subviews] objectAtIndex:0] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] subviews] objectAtIndex:2] text];
	NSURLCredential *credential = [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistencePermanent];
	[ASIHTTPRequest saveCredentials:credential forHost:[[request url] host] port:[[[request url] port] intValue] protocol:[[request url] scheme] realm:[request authenticationRealm]];
	
	//[[self request] setUsername:username];
	//[[self request] setPassword:password];
	
	[[self loginDialog] dismissWithClickedButtonIndex:1 animated:YES];
	
	// advise delegate that credentials have been entered
	if ([delegate respondsToSelector:@selector(credentialsEntered)])
        [delegate credentialsEntered];
    else
    { 
        [NSException raise:NSInternalInconsistencyException format:@"Delegate doesn't respond to credentialsEntered"];
    }	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (section == [self numberOfSectionsInTableView:tableView]-1)
	{
		return 50;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 7;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	
	if (section == 0)
	{
		return @" ";
		//return @"mindegg.com";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_3_0
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
#else
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
#endif

	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(20,12,260,25)] autorelease];
	[textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	if ([indexPath section] == 0)
	{
		[textField setPlaceholder:@"Username"];
		if (![username isEqualToString:@""])
		{
			[textField setText:username];
		}
	}
	else if ([indexPath section] == 1)
	{
		[textField setPlaceholder:@"Password"];
		[textField setSecureTextEntry:YES];
	}	
	[cell addSubview:textField];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == [self numberOfSectionsInTableView:tableView]-1)
	{	
		return @"You can download existing cards without an account by supplying a Deck ID.";
		//return @"No account required to download existing cards by Deck ID.";
	}
	return nil;
}

@synthesize request;
@synthesize delegate;
@synthesize username;
@synthesize loginDialog;
@synthesize repeatAttempt;
@end
