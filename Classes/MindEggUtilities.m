//
//  MindEggUtilities.m
//  MindEgg
//
//  Created by Dave Thompson on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MindEggUtilities.h"
#import "Constants.h"

@implementation MindEggUtilities

+ (void)mindEggErrorAlertWithMessage:(NSString *)aMessage
{
	// tell user that there was a problem and that decks are not being synchronised
	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: [ERROR_DIALOG_TITLE copy]
							   message: aMessage
							   delegate: nil
							   cancelButtonTitle: @"OK"
							   otherButtonTitles: nil];
	[errorAlert show];
	[errorAlert release];
}

@end
