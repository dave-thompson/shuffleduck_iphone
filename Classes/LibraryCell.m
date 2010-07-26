//
//  LibraryCell.m
//  ShuffleDuck
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LibraryCell.h"
#import "Constants.h"
#import "VariableStore.h"
#import "MyDecksViewController.h"
#import "DeckDownloader.h"

@implementation LibraryCell

@synthesize sideView, remainLabel, titleLabel, mainView;

BOOL isFullyDownloaded;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	if (isFullyDownloaded) // selection only allowed on fully downloaded decks
	{
		if (selected)
		{
			// set background to blue and text to white
			mainView.backgroundColor = [UIColor blueColor];
			titleLabel.backgroundColor = [UIColor blueColor];
			remainLabel.backgroundColor = [UIColor blueColor];
			
			titleLabel.textColor = [UIColor whiteColor];
			remainLabel.textColor = [UIColor whiteColor];
		}
		else
		{
			// restore to original colors
			mainView.backgroundColor = [UIColor whiteColor];
			titleLabel.backgroundColor = [UIColor whiteColor];
			remainLabel.backgroundColor = [UIColor whiteColor];
			
			titleLabel.textColor = [UIColor blackColor];
			remainLabel.textColor = [[VariableStore sharedInstance] mindeggGreyText];
		}
	}
}

- (void)setFullyDownloaded:(BOOL)fullyDownloaded withTitle:(NSString *)theTitle numKnownCards:(int)theNumKnownCards numUnknownCards:(int)theNumUnknownCards
{
	isFullyDownloaded = fullyDownloaded;
	
	if (isFullyDownloaded) // if a deck is fully downloaded, show a normal cell
	{
		remainLabel.text = [NSString stringWithFormat:@"%d left", theNumUnknownCards];
		remainLabel.textColor = [[VariableStore sharedInstance] mindeggGreyText];

		titleLabel.text = theTitle;
		titleLabel.textColor = [UIColor blackColor];
	}
	else // if a deck is not fully downloaded, show either a'processing' or 'resume download' cell
	{
		if ((!([MyDecksViewController sharedInstance].syncButton.enabled)) || ([DeckDownloader downloadIsInProgress])) // if either a sync or download is in progress, show cell to be 'processing'
		{
			UIColor *disabledColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
			
			remainLabel.text = @"Processing....";
			remainLabel.textColor = disabledColor;
			
			titleLabel.text = theTitle;
			titleLabel.textColor = disabledColor;
		}
		else // a download is not in progress - invite the user to resume it
		{
			UIColor *disabledColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];

			remainLabel.text = @"Tap to resume download";
			remainLabel.textColor = disabledColor;
			
			titleLabel.text = theTitle;
			titleLabel.textColor = disabledColor;
		}
	}
}

- (void)dealloc {
	[sideView release];
	[sideViewController release];
	[remainLabel release];
	[titleLabel release];
    [super dealloc];
}


@end
