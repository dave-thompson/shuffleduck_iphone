//
//  RandomColor.m
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RandomColor.h"

@implementation RandomColor


+(UIColor *)randomColorWithStateUpdate:(sqlite3 *)databaseForStateUpdate
{
	// create random red, green, blue values
	CGFloat red = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	
	// if a database was specified, write the new color to the DB
			sqlite3_stmt *updateStmt = nil;

			if(updateStmt == nil)
			{
				const char *sql = "update Setting Set red_color = ?, blue_color = ?, green_color = ?";
				if(sqlite3_prepare_v2(databaseForStateUpdate, sql, -1, &updateStmt, NULL) != SQLITE_OK)
					NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(databaseForStateUpdate));
			}
			else
			{
				NSLog(@"Error: updatestmt not nil");
			}
			
			sqlite3_bind_double(updateStmt, 1, red);
			sqlite3_bind_double(updateStmt, 2, blue);
			sqlite3_bind_double(updateStmt, 3, green);
			
			if(SQLITE_DONE != sqlite3_step(updateStmt))
			{NSAssert1(0, @"Error while updating DB with new color values. '%s'", sqlite3_errmsg(databaseForStateUpdate));}
			
			sqlite3_reset(updateStmt);
			updateStmt = nil;
	
	NSLog(@"Red:%f Blue:%f Green:%f", red, blue, green);
	
	// return new color
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	
}

+(UIColor *)randomColor
{
	// create random red, green, blue values
	CGFloat red = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	// return new color
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end





/*

 */



