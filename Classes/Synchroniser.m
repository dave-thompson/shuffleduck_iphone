//
//  DeckDownloader.m
//  MindEgg
//
//
//  Created by Dave Thompson on 1/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Synchroniser.h"
#import "DDXML.h"
#import "ASIHTTPRequest.h"
#import "VariableStore.h"
#import "MyDecksViewController.h"
#import "ProgressViewController.h"
#import "Constants.h"
#import "ASIAuthenticationDialog.h"
#import "MindEggUtilities.h"
#import "DeckDownloader.h"
#import "DeckDownloaderQueueItem.h"
static Synchroniser *sharedSynchroniser = nil;

@implementation Synchroniser

#pragma mark -
#pragma mark Web Service Methods

+ (Synchroniser *)sharedInstance
{
	@synchronized(self)
	{
		if (!sharedSynchroniser)
		{
			sharedSynchroniser = [[[self class] alloc] init];
		}
	}
    return sharedSynchroniser;
}

-(void)synchronise
{
	// disable sync button
	[MyDecksViewController sharedInstance].syncButton.enabled = NO;
	
	// setup URL
	NSURL *url = [NSURL URLWithString:[CONTEXT_URL stringByAppendingString:[NSString stringWithFormat:@"/decks"]]];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	// check for credentials in the keychain
	NSURLCredential *authenticationCredentials = [ASIHTTPRequest savedCredentialsForHost:[[request url] host] port:[[[request url] port] intValue] protocol:[[request url] scheme] realm:[request authenticationRealm]];
	if (authenticationCredentials) // if credentials exist, request the deck list
	{
		// show busy indicator
		//[ProgressViewController startShowingProgress];
		// send request
		[request setUsername:[authenticationCredentials user]];
		[request setPassword:[authenticationCredentials password]];
		[request setDelegate:self];
		[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[authenticationCredentials user], @"username", nil]];
		[request setDidFinishSelector:@selector(deckListRequestFinished:)];
		[request setDidFailSelector:@selector(deckListRequestFailed:)];
		[request startAsynchronous];		
	}
	else // no credentials exist, so ask for them
	{
		[ASIAuthenticationDialog presentAuthenticationDialogForRequest:request delegate:self username:@"" repeatAttempt:NO];
	}
}

- (void) credentialsEntered
{
	// have another go at syncing, using the newly entered credentials
	[self synchronise];
}

- (void) deckListRequestFinished:(ASIHTTPRequest *)request
{
	DDXMLDocument *doc;
	NSString *responseString = [request responseString];
	doc = [[DDXMLDocument alloc] initWithXMLString:responseString options:0 error:nil];
	if (doc == nil)	{[doc release];	return;}
	
	DDXMLElement *rootElement = [doc rootElement];
	if ([XML_ERROR_TAG isEqualToString:[rootElement name]]) // if the server returned an error...
	{
		// remove busy indicator
		[ProgressViewController stopShowingProgress];		
		
		// what are the specifics of the failure?
		BOOL userRecognised = [[[[rootElement elementsForName:@"logon_succeeded"] objectAtIndex:0] stringValue] boolValue];
		NSString *username = [request.userInfo valueForKey:@"username"];
		
		// if the error was due to a failed logon, show the credentials dialog
		if (!(userRecognised))
		{
			[ASIAuthenticationDialog presentAuthenticationDialogForRequest:request delegate:self username:username repeatAttempt:YES];
		}
		else // otherwise, just notify the user of the failure
		{
			NSString *error_description = [[[rootElement elementsForName:@"description"] objectAtIndex:0] stringValue];
			[MindEggUtilities mindEggErrorAlertWithMessage:error_description];

			// enable the sync button
			[MyDecksViewController sharedInstance].syncButton.enabled = YES;
		}
	}
	else // the server returned the deck summary information, so process this and then ask for the full deck
	{
		NSMutableArray *downloadQueue = [[NSMutableArray alloc] initWithCapacity:1]; // a local LIFO queue used to reverse the order of the deck to be downloaded (metadata should be downloaded oldest deck first, but full deck data is downladed newest deck first)

		// populate database based on retrieved xml_string
		int numberDecksReceived = [[[doc rootElement] elementsForName:@"deck"] count];
		
		// remove busy indicator for now (deckparser will put it back on for each individual deck download - the gap shouldn't be noticeable to the user)
		//[ProgressViewController stopShowingProgress];
		
		// loop through the decks received, adding them to the screen
		for (int i = (numberDecksReceived - 1); i >= 0; i--)
		{
			// check if this deck already exists on iphone
				DDXMLElement *deckElement = (DDXMLElement *)[[[doc rootElement] elementsForName:@"deck"] objectAtIndex: i];
				int userVisibleID = [[[[deckElement elementsForName:@"user_visible_id"] objectAtIndex: 0] stringValue] integerValue];
				
				BOOL deckExistsAlready = NO;
				const char *sqlStatement = "SELECT user_visible_id FROM Deck WHERE user_visible_id =?;";
				sqlite3_stmt *compiledStatement;
				if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
				{
					sqlite3_bind_int(compiledStatement,1,userVisibleID);
					while(sqlite3_step(compiledStatement) == SQLITE_ROW) // if a row is returned
					{
						deckExistsAlready = YES;
					}
				}
				sqlite3_finalize(compiledStatement);
			
			// if the deck doesn't already exist, retrieve it
				if (!(deckExistsAlready))
				{
					// get remaining metadata
					NSString *title = [[[deckElement elementsForName:@"title"] objectAtIndex: 0] stringValue];
					NSString *author = [[[deckElement elementsForName:@"author"] objectAtIndex: 0] stringValue];				
					
					// create a new deck on the Library screen, with metadata only
					int deckID = [DeckDownloader insertNewDeckMetadataToDBWithUserVisibleID:userVisibleID title:title author:author];
					
					// store the deck reference
					DeckDownloaderQueueItem *queueItem = [[DeckDownloaderQueueItem alloc] initWithUserVisibleID:userVisibleID iPhoneSpecificID:deckID];
					[downloadQueue addObject:queueItem];
				}
		}
		
		// loop through the decks received again in the opposite direction, this time downloading the full deck
		for (int i = ([downloadQueue count] - 1); i >= 0; i--)
		{
			// start downloading the full deck
			DeckDownloaderQueueItem *queueItem = [downloadQueue objectAtIndex:i];
			[[DeckDownloader sharedInstance] completeDownloadOfDeckID:[queueItem userVisibleID] withIPhoneDeckID:[queueItem iPhoneDeckID]];
		}
		
		[downloadQueue release];
	}
	
	// clean up
	[doc release];
}

- (void) deckListRequestFailed:(ASIHTTPRequest *)request
{
	// remove busy indicator
	// [ProgressViewController stopShowingProgress];
	
	// tell user that there was a problem and that decks are not being synchronised
 	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle:  [NSString stringWithFormat:@"Couldn't Synchronize Decks"]
							   message: [NSString stringWithFormat:@"Please check your network connection and try again."]
							   delegate: nil
							   cancelButtonTitle: @"OK"
							   otherButtonTitles: nil];
	[errorAlert show];
	[errorAlert release];
	
	// enable the sync button
	[MyDecksViewController sharedInstance].syncButton.enabled = YES;
}


- (void)dealloc {
    [super dealloc];
}

@end
