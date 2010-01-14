//
//  SideViewController.m
//  MindEgg
//
//  Created by Dave Thompson on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SideViewController.h"


@implementation SideViewController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
 {
	 _sizeMultiplier = 1.0;
 }
 return self;
 }


-(void)setCustomSizeByWidth:(uint)widthInPixels
{
	_sizeMultiplier = (float)widthInPixels / (float)260;
	int width = 260 * _sizeMultiplier;
	int height = 160 * _sizeMultiplier;
	self.view.bounds = CGRectMake(0, 0, width, height);
}

-(void)clearSide
{
	// for each label or image on the side
	for (UIView *view in self.view.subviews)
	{
		// remove the label or image from the side
		[view removeFromSuperview];
		// release the label or image from memory
		[view release];
	}
}

-(void)replaceSideWithSideID:(int)sideID FromDB:(sqlite3 *)sourceDatabase
{
	// clear the old side
	[self clearSide];
	
	// Retrieve all components on the new side from the DB
	NSString *sqlString = [NSString stringWithFormat:@"SELECT Component.type, Component.x, Component.y, Component.width, Component.height, TextBox.text, TextBox.font_id, TextBox.font_size, TextBox.foreground_red, TextBox.foreground_green, TextBox.foreground_blue, TextBox.foreground_alpha, TextBox.background_red, TextBox.background_green, TextBox.background_blue, TextBox.background_alpha, TextBox.alignment_id, Image.image FROM Component LEFT OUTER JOIN TextBox ON Component.id = TextBox.component_id LEFT OUTER JOIN Image ON Component.id = Image.component_id WHERE Component.side_id = %d ORDER BY Component.display_order ASC;",sideID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2(sourceDatabase, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		// Process each returned row (== component) in turn
		while(sqlite3_step(compiledStatement) == SQLITE_ROW)
		{
			// retrieve data common to all components
			int componentType = (int)sqlite3_column_int(compiledStatement, 0);
			int x = (int)sqlite3_column_int(compiledStatement, 1);
			int y = (int)sqlite3_column_int(compiledStatement, 2);
			int width = (int)sqlite3_column_int(compiledStatement, 3);
			int height = (int)sqlite3_column_int(compiledStatement, 4);
			
			// transform size properties according to side size
			x = x * _sizeMultiplier;
			y = y * _sizeMultiplier;
			width = width * _sizeMultiplier;
			height = height * _sizeMultiplier;
			
			switch(componentType)
			{
					
				case 1: // textbox
					
					x = x; // don't know why this line is required; it doesn't do anything but removing it causes a syntax error (it was written explictly to resolve this error)
					
					// retrieve textbox specific data
					NSString *displayText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
					// int font_id = (int)sqlite3_column_int(compiledStatement, 6);
					CGFloat font_size = (CGFloat)sqlite3_column_double(compiledStatement, 7);					
					CGFloat foreground_red = (CGFloat)sqlite3_column_double(compiledStatement, 8);
					CGFloat foreground_green = (CGFloat)sqlite3_column_double(compiledStatement, 9);
					CGFloat foreground_blue = (CGFloat)sqlite3_column_double(compiledStatement, 10);
					CGFloat foreground_alpha = (CGFloat)sqlite3_column_double(compiledStatement, 11);					
					CGFloat background_red = (CGFloat)sqlite3_column_double(compiledStatement, 12);
					CGFloat background_green = (CGFloat)sqlite3_column_double(compiledStatement, 13);
					CGFloat background_blue = (CGFloat)sqlite3_column_double(compiledStatement, 14);
					CGFloat background_alpha = (CGFloat)sqlite3_column_double(compiledStatement, 15);
					int alignment_id = (int)sqlite3_column_int(compiledStatement, 16);
					
					// transform size properties according to side size
					font_size = font_size * _sizeMultiplier;
					
					
					// create label and set properties
					UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
					label.text = displayText;
					label.font = [UIFont fontWithName:@"Arial" size: font_size];
					switch(alignment_id)
					{
					 case 1:
						label.textAlignment = UITextAlignmentLeft;
						break;
					 case 2:
						label.textAlignment = UITextAlignmentCenter;						
						break;
					 case 3:
						label.textAlignment = UITextAlignmentRight;
						break;
					}
					label.textColor = [UIColor colorWithRed:foreground_red green:foreground_green blue:foreground_blue alpha:foreground_alpha];
					label.backgroundColor = [UIColor colorWithRed:background_red green:background_green blue:background_blue alpha:background_alpha];
					label.lineBreakMode = UILineBreakModeClip;
					[self.view addSubview:label];
					
					break;
					
				case 2: // image
					
					x = x; // don't know why this line is required; it doesn't do anything but removing it causes a syntax error (it was written explictly to resolve this error)
					
					// retrieve image from DB
					NSData *componentImageData = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, 17) length:sqlite3_column_bytes(compiledStatement, 17)];
					UIImage *componentImage;
					if(componentImageData == nil)
					{
						NSLog(@"No image found when loading component image data with sideID %d.", sideID);
						componentImage = nil;
					}
					else
					{
						componentImage = [UIImage imageWithData:componentImageData];
					}
					
					// create image view and set properties
					UIImageView *componentImageView = [[UIImageView alloc] initWithImage:componentImage];
					componentImageView.frame = CGRectMake(x, y, width, height);
					componentImageView.contentMode = UIViewContentModeScaleAspectFit;
					[self.view addSubview:componentImageView];
					[componentImageData release]; // THIS MEMORY RELEASE NOT TESTED AS WORKING - IF PROBLEMS ARISE LATER WITH IMAGES, TRY COMMENTING THIS OUT
					
					break;
			}
		}
	}
	else
	{
		NSLog([NSString stringWithFormat:@"SQLite request failed with message: %s", sqlite3_errmsg(sourceDatabase)]); 
	}
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
