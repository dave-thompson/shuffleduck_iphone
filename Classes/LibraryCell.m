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

@synthesize deckTitle, miniCardView, known, unknown, miniCardViewController, knownDescriptionLabel, unknownDescriptionLabel, mainView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
        // set up colours
		unknownDescriptionLabel.textColor = [[VariableStore sharedInstance] mindeggGreen];
		knownDescriptionLabel.textColor = [[VariableStore sharedInstance] mindeggRed];
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
		known.textColor = [[VariableStore sharedInstance] mindeggGreen];
		unknown.textColor = [[VariableStore sharedInstance] mindeggRed];
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
