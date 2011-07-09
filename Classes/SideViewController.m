//
//  SideViewController.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SideViewController.h"
#import "VariableStore.h"
#import "CustomLabel.h"

#define UIColorFromRGB(rgbValue) [UIColor \
  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
         green:((float)((rgbValue & 0xFF00)  >> 8))/255.0 \
          blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation SideViewController

 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
	// clear the background color
	self.view.backgroundColor = [UIColor whiteColor];
	
	// for each label or image on the side
	for (UIView *view in self.view.subviews)
	{
		// remove the label or image from the side
		[view removeFromSuperview];
		// release the label or image from memory
		[view release];
	}
}

-(void)replaceSideWithSideID:(int)sideID
{
	// clear the old side
	[self clearSide];
	
	
	// Set the side background colour
	NSString *sqlString = [NSString stringWithFormat:@"SELECT background_color FROM Side WHERE id = %d;",sideID];
	const char *sqlStatement = [sqlString UTF8String];
	sqlite3_stmt *compiledStatement;
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
	{
		while(sqlite3_step(compiledStatement) == SQLITE_ROW) // should be just one row
		{
			int side_background_color = (int)sqlite3_column_int(compiledStatement, 0);
			self.view.backgroundColor = UIColorFromRGB(side_background_color);		
		}
	}
	sqlite3_reset(compiledStatement);
	compiledStatement = nil;

	// Retrieve all components on the new side from the DB
	sqlString = [NSString stringWithFormat:@"SELECT Component.type, Component.x, Component.y, Component.width, Component.height, TextBox.text, TextBox.font_id, TextBox.font_size, TextBox.foreground_color, TextBox.foreground_alpha, TextBox.background_color, TextBox.background_transparent, TextBox.background_alpha, TextBox.alignment_id, Image.image FROM Component LEFT OUTER JOIN TextBox ON Component.id = TextBox.component_id LEFT OUTER JOIN Image ON Component.id = Image.component_id WHERE Component.side_id = %d ORDER BY Component.display_order ASC;",sideID];
	sqlStatement = [sqlString UTF8String];
	if(sqlite3_prepare_v2([VariableStore sharedInstance].database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
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
			
			
			// hack to increase textbox height if this is a mini text-box (so that text isn't cut off due to font's leading value being an integer and therefore not scaling perfectly)
			if ((_sizeMultiplier == (float)91 / (float)260) && (height==56)) // if this is a mini side on the library tableview
			// EXPERIMENTING TO FIX LEADING ISSUE - WORK TO BE DONE HERE - LEFT IN TEMP STATE
			{
				// set height to slightly larger to allow all text to fit on
				height = height * 1.08;
				y = (height * -0.04);
				//height = 60;
				//y = -2;
			}
			
			
			switch(componentType)
			{
					
				case 1: // textbox
					
					x = x; // don't know why this line is required; it doesn't do anything but removing it causes a syntax error (it was written explictly to resolve this error)
					
					// retrieve textbox specific data
					NSString *displayText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
					// int font_id = (int)sqlite3_column_int(compiledStatement, 6);
					CGFloat font_size = (CGFloat)sqlite3_column_double(compiledStatement, 7);					
					int foreground_color = (int)sqlite3_column_int(compiledStatement, 8);
					// CGFloat foreground_alpha = (CGFloat)sqlite3_column_double(compiledStatement, 9);
					int background_color = (int)sqlite3_column_int(compiledStatement, 10);
					BOOL background_transparent = (BOOL)sqlite3_column_int(compiledStatement, 11);
					// CGFloat background_alpha = (CGFloat)sqlite3_column_double(compiledStatement, 12);
					int alignment_id = (int)sqlite3_column_int(compiledStatement, 13);
					
					// transform size properties according to side size
					font_size = font_size * _sizeMultiplier;
					
					
					// create label and set properties
					UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
					label.text = displayText;
					
					label.font = [UIFont fontWithName:@"Arial" size: font_size]; // familyName == "Arial", font name == "ArialMT"
					
					UIFont *testFont = label.font;
					CGFloat testSize = testFont.pointSize;
					CGFloat ascender = testFont.ascender;
					CGFloat descender = testFont.descender;
					CGFloat leading = testFont.leading;
					
					
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
					label.textColor = UIColorFromRGB(foreground_color);
					if (background_transparent)
						label.backgroundColor = [UIColor clearColor];
					else
						label.backgroundColor = UIColorFromRGB(background_color);
					label.numberOfLines = 0;
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
						[componentImageData release];
					}
					
					// create image view and set properties
					UIImageView *componentImageView = [[UIImageView alloc] initWithImage:componentImage];
					componentImageView.frame = CGRectMake(x, y, width, height);
					componentImageView.contentMode = UIViewContentModeScaleAspectFit;
					[self.view addSubview:componentImageView];
					[componentImageView release];
					
					break;
			}
		}
	}
	else
	{
		NSLog(@"SQLite request failed with message: %s", sqlite3_errmsg([VariableStore sharedInstance].database)); 
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
