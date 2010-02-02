//
//  LibraryCell.m
//  MindEgg
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LibraryCell.h"
#import "Constants.h"
#import "VariableStore.h"

@implementation LibraryCell

@synthesize miniCardView, leftMultipartLabel, rightMultipartLabel, titleLabel, miniCardViewController, mainView;

BOOL isFullyDownloaded;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
    }
    return self;
}


- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// set up multipart labels
	[leftMultipartLabel updateNumberOfLabels:2 fontSize:12 alignment:MultipartLabelLeft];
	[leftMultipartLabel setText:@"Unknown:  " andColor:[[VariableStore sharedInstance] mindeggGreyText] forLabel:0];
	[leftMultipartLabel setText:@"" andColor:[[VariableStore sharedInstance] mindeggRed] forLabel:1];
	
	[rightMultipartLabel  updateNumberOfLabels:2 fontSize:12 alignment:MultipartLabelLeft];
	[rightMultipartLabel setText:@"Known:  " andColor:[[VariableStore sharedInstance] mindeggGreyText] forLabel:0];
	[rightMultipartLabel setText:@"" andColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:1];	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	if (isFullyDownloaded) // selection only allowed on fully downloaded decks
	{
		if (selected)
		{
			// set background to blue and text to white
			mainView.backgroundColor = [UIColor blueColor];
			
			[leftMultipartLabel setColor:[UIColor whiteColor] forLabel:0];
			[leftMultipartLabel setColor:[UIColor whiteColor] forLabel:1];

			[rightMultipartLabel setColor:[UIColor whiteColor] forLabel:0];
			[rightMultipartLabel setColor:[UIColor whiteColor] forLabel:1];
			
			titleLabel.textColor = [UIColor whiteColor];
		}
		else
		{
			// restore to original colors
			mainView.backgroundColor = [UIColor whiteColor];
			
			[leftMultipartLabel setColor:[[VariableStore sharedInstance] mindeggRed] forLabel:0];
			[leftMultipartLabel setColor:[[VariableStore sharedInstance] mindeggRed] forLabel:1];
			
			[rightMultipartLabel setColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:0];
			[rightMultipartLabel setColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:1];
			
			titleLabel.textColor = [UIColor blackColor];
		}
	}
}

- (void)setFullyDownloaded:(BOOL)fullyDownloaded withTitle:(NSString *)theTitle numKnownCards:(int)theNumKnownCards numUnknownCards:(int)theNumUnknownCards
{
	isFullyDownloaded = fullyDownloaded;
	
	if (isFullyDownloaded)
	{
		[leftMultipartLabel setText:@"Remaining:  " andColor:[[VariableStore sharedInstance] mindeggRed] forLabel:0];
		[leftMultipartLabel setText:[NSString stringWithFormat:@"%d", theNumUnknownCards] forLabel:1];

		[rightMultipartLabel setText:@"Known:  " andColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:0]; 
		[rightMultipartLabel setText:[NSString stringWithFormat:@"%d", theNumKnownCards] forLabel:1];

		titleLabel.text = theTitle;
		titleLabel.textColor = [UIColor blackColor];
	}
	else
	{
		UIColor *disabledColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
		
		[leftMultipartLabel setText:@"Processing...." andColor:disabledColor forLabel:0];
		[leftMultipartLabel setText:@"" forLabel:1];

		[rightMultipartLabel setText:@"" forLabel:0];
		[rightMultipartLabel setText:@"" forLabel:1];

		titleLabel.text = theTitle;
		titleLabel.textColor = disabledColor;
	}
}

- (void)dealloc {
	[miniCardView release];
	[miniCardViewController release];
	[leftMultipartLabel release];
	[rightMultipartLabel release];
	[titleLabel release];
    [super dealloc];
}


@end
