//
//  VariableStore.h
//  MindEgg
//
//  Created by Dave Thompson on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface VariableStore : NSObject
{
	UIColor *backgroundColor;
	UIColor *mindeggGreen;
	UIColor *mindeggRed;
	UIColor *mindeggGreyText;
	NSString *contextURL;
	sqlite3 *database;
	
	NSOperationQueue *queue; // not currently used
}

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *mindeggGreen;
@property (nonatomic, retain) UIColor *mindeggRed;
@property (nonatomic, retain) UIColor *mindeggGreyText;
@property (nonatomic, retain) NSString *contextURL;
@property (nonatomic, retain) NSOperationQueue *queue;

@property (nonatomic, assign) sqlite3 *database;

+ (VariableStore *)sharedInstance;

@end
