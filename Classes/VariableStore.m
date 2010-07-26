//
//  VariableStore.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VariableStore.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00)  >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation VariableStore

@synthesize backgroundColor, contextURL, mindeggGreen, mindeggRed, mindeggGreyText, database, queue;

+ (VariableStore *)sharedInstance
{
    // the instance of this class is stored here
    static VariableStore *myInstance = nil;
	
    // check to see if an instance already exists
    if (nil == myInstance)
	{
        myInstance  = [[[self class] alloc] init];
        // initialize variables
		myInstance.backgroundColor = UIColorFromRGB(0x87989E); // [UIColor groupTableViewBackgroundColor]; // old, grey color [UIColor colorWithRed:0.525747001 green:0.596195996 blue:0.618924975 alpha:1.0];
		//myInstance.mindeggGreen = [UIColor colorWithRed:(0/255.0) green:(115/255.0) blue:(2/255.0) alpha:1.0]; // #007302 (green)
		//myInstance.mindeggRed = [UIColor colorWithRed:(255/255.0) green:(43/255.0) blue:(10/255.0) alpha:1.0]; // #FF2B0A (red)
		myInstance.mindeggRed = UIColorFromRGB(0xE72910); //[UIColor colorWithRed:(231/255.0) green:(41/255.0) blue:(16/255.0) alpha:1.0]; // #E72910 (red)
		myInstance.mindeggGreen = UIColorFromRGB(0x00A304); //[UIColor colorWithRed:(0/255.0) green:(163/255.0) blue:(4/255.0) alpha:1.0]; // #00A304 (green)
		myInstance.mindeggGreyText = UIColorFromRGB(0x878787); //[UIColor colorWithRed:(135/255.0) green:(135/255.0) blue:(135/255.0) alpha:1.0]; // #878787 (grey)
		myInstance.database = nil;
		
		myInstance.queue = [[NSOperationQueue alloc] init];
    }
    // return the instance of this class
    return myInstance;
}

- (void)dealloc {
	[queue release], queue = nil;
	[backgroundColor release];
	[mindeggRed release];
	[mindeggGreen release];
	[mindeggGreyText release];
	[super dealloc];
}

@end

