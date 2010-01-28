//
//  VariableStore.m
//  MindEgg
//
//  Created by Dave Thompson on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VariableStore.h"

@implementation VariableStore

@synthesize backgroundColor, contextURL, mindeggGreen, mindeggRed;

+ (VariableStore *)sharedInstance
{
    // the instance of this class is stored here
    static VariableStore *myInstance = nil;
	
    // check to see if an instance already exists
    if (nil == myInstance)
	{
        myInstance  = [[[self class] alloc] init];
        // initialize variables
		myInstance.backgroundColor = [UIColor colorWithRed:0.525747001 green:0.596195996 blue:0.618924975 alpha:1.0];
		myInstance.mindeggGreen = [UIColor colorWithRed:(0/255.0) green:(115/255.0) blue:(2/255.) alpha:1.0]; // #007302 (green)
		myInstance.mindeggRed = [UIColor colorWithRed:(255/255.0) green:(43/255.0) blue:(10/255.) alpha:1.0]; // #FF2B0A (red)
    }
    // return the instance of this class
    return myInstance;
}

- (void)dealloc {
	[backgroundColor release];
	[super dealloc];
}

@end

