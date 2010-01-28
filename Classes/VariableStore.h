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
	NSString *contextURL;
}

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) NSString *contextURL;

+ (VariableStore *)sharedInstance;

@end