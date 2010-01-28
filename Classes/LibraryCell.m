//
//  LibraryCell.m
//  MindEgg
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LibraryCell.h"

@implementation LibraryCell

@synthesize deckTitle, miniCardView, known, unknown, miniCardViewController, knownDescriptionLabel, unknownDescriptionLabel, mainView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

   //[super setSelected:selected animated:animated];

	if (selected == YES)
	{
		// set background to blue and text to white
		mainView.backgroundColor = [UIColor blueColor];
		deckTitle.textColor = [UIColor whiteColor];
		unknownDescriptionLabel.textColor = [UIColor whiteColor];
		knownDescriptionLabel.textColor = [UIColor whiteColor];
		known.textColor = [UIColor whiteColor];
		unknown.textColor = [UIColor whiteColor];
	}
	else
	{
		// restore to original colors
		mainView.backgroundColor = [UIColor whiteColor];
		deckTitle.textColor = [UIColor blackColor];
		unknownDescriptionLabel.textColor = [UIColor colorWithRed:(135/255.0) green:(135/255.0) blue:(135/255.) alpha:1.0]; // #878787 (grey)
		knownDescriptionLabel.textColor = [UIColor colorWithRed:(135/255.0) green:(135/255.0) blue:(135/255.) alpha:1.0]; // #878787 (grey)
		known.textColor = [UIColor colorWithRed:(0/255.0) green:(115/255.0) blue:(2/255.) alpha:1.0]; // #007302 (green)
		unknown.textColor = [UIColor colorWithRed:(255/255.0) green:(43/255.0) blue:(10/255.) alpha:1.0]; // #FF2B0A (red)		
	}
	 
}


- (void)dealloc {
	[deckTitle release];
	[miniCardView release];
	[known release];
	[unknown release];
	[miniCardViewController release];
    [super dealloc];
}


@end
