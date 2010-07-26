//
//  ShuffleDuckUtilities.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShuffleDuckUtilities.h"
#import "Constants.h"
#import "sqlite3.h"
#import "VariableStore.h"

@implementation ShuffleDuckUtilities

static sqlite3_stmt *updateStmt = nil;

+ (void)shuffleDuckErrorAlertWithMessage:(NSString *)aMessage
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


+ (void)runSQLUpdate:(NSString *)sqlString
{	
	if(updateStmt == nil)
	{
		const char *sql = [sqlString UTF8String];
		if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
		{
			NSLog(@"Error while creating delete statement. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
		}
	}
	
	if (SQLITE_DONE != sqlite3_step(updateStmt))
		NSLog(@"Error while deleting. '%s'", sqlite3_errmsg([VariableStore sharedInstance].database));
	
	sqlite3_reset(updateStmt);
	updateStmt = nil;
}

+(int)getIntUsingSQL:(NSString *)sqlString
{
	int returnValue = -1;
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			returnValue = (int)sqlite3_column_int(compiledStatement, 0);
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return returnValue;
}

+(NSString *)getStringUsingSQL:(NSString *)sqlString
{
	NSString *returnValue = @"";
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			returnValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
	}
	return returnValue;
}

@end
