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

@synthesize deckTitle, miniCardView, leftMultipartLabel, rightMultipartLabel, miniCardViewController, mainView;


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
	[deckTitle updateNumberOfLabels:1 fontSize:16 alignment:MultipartLabelLeft];
	[deckTitle setText:@"<Deck Title>" andColor:[UIColor blackColor] forLabel:0];
	
	[leftMultipartLabel updateNumberOfLabels:2 fontSize:12 alignment:MultipartLabelLeft];
	[leftMultipartLabel setText:@"Unknown:  " andColor:[[VariableStore sharedInstance] mindeggGreyText] forLabel:0];
	[leftMultipartLabel setText:@"" andColor:[[VariableStore sharedInstance] mindeggRed] forLabel:1];
	
	[rightMultipartLabel  updateNumberOfLabels:2 fontSize:12 alignment:MultipartLabelLeft];
	[rightMultipartLabel setText:@"Known:  " andColor:[[VariableStore sharedInstance] mindeggGreyText] forLabel:0];
	[rightMultipartLabel setText:@"" andColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:1];	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

   //[super setSelected:selected animated:animated];

	if (selected == YES)
	{
		// set background to blue and text to white
		mainView.backgroundColor = [UIColor blueColor];
		[deckTitle setColor:[UIColor whiteColor] forLabel:0];
		[leftMultipartLabel setColor:[UIColor whiteColor] forLabel:1];
		[rightMultipartLabel setColor:[UIColor whiteColor] forLabel:1];
	}
	else
	{
		// restore to original colors
		mainView.backgroundColor = [UIColor whiteColor];
		[deckTitle setColor:[UIColor blackColor] forLabel:0];
		[leftMultipartLabel setColor:[[VariableStore sharedInstance] mindeggRed] forLabel:1];
		[rightMultipartLabel setColor:[[VariableStore sharedInstance] mindeggGreen] forLabel:1];

	}
}

- (void)dealloc {
	[deckTitle release];
	[miniCardView release];
	[miniCardViewController release];
	[leftMultipartLabel release];
	[rightMultipartLabel release];
    [super dealloc];
}


@end
