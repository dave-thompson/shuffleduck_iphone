//  MultipartLabel.m
//  MultiLabelLabel
//
//  Created by Jason Miller on 10/7/09.
//  Copyright 2009 Jason Miller. All rights reserved.
//

#import "MultipartLabel.h"

@interface MultipartLabel (Private)
- (void)updateLayout;
@end

@implementation MultipartLabel

@synthesize containerView;
@synthesize labels;

-(void)updateNumberOfLabels:(int)numLabels;
{
	[containerView removeFromSuperview];
	self.containerView = nil;
	
	self.containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
	containerView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
	[self addSubview:self.containerView];
	self.labels = [NSMutableArray array];
	
	while (numLabels-- > 0) {
		UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.font = [UIFont fontWithName:@"Helvetica" size:13];
		label.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
		[self.containerView addSubview:label];
		[self.labels addObject:label];
		[label release];
	}
	
	[self updateLayout];
}

-(void)setText:(NSString *)text forLabel:(int)labelNum;
{
	if( [self.labels count] > labelNum && labelNum >= 0 )
	{
		UILabel * thisLabel = [self.labels objectAtIndex:labelNum];
		thisLabel.text = text;
	}
	
	[self updateLayout];
}

-(void)setText:(NSString *)text andFont:(UIFont*)font forLabel:(int)labelNum;
{
	if( [self.labels count] > labelNum && labelNum >= 0 )
	{
		UILabel * thisLabel = [self.labels objectAtIndex:labelNum];
		thisLabel.text = text;
		thisLabel.font = font;
	}
	
	[self updateLayout];
}

-(void)setText:(NSString *)text andColor:(UIColor*)color forLabel:(int)labelNum;
{
	if( [self.labels count] > labelNum && labelNum >= 0 )
	{
		UILabel * thisLabel = [self.labels objectAtIndex:labelNum];
		thisLabel.text = text;
		thisLabel.textColor = color;
	}
	
	[self updateLayout];
}

-(void)setText:(NSString *)text andFont:(UIFont*)font andColor:(UIColor*)color forLabel:(int)labelNum;
{
	if( [self.labels count] > labelNum && labelNum >= 0 )
	{
		UILabel * thisLabel = [self.labels objectAtIndex:labelNum];
		thisLabel.text = text;
		thisLabel.font = font;
		thisLabel.textColor = color;
	}
	
	[self updateLayout];
}

- (void)updateLayout {
	
	/*
	// For left alignment, use this block rather than the following one
	int thisX = 0;
	
	for (UILabel * thisLabel in self.labels)
	{
		CGSize size = [thisLabel.text sizeWithFont:thisLabel.font constrainedToSize:CGSizeMake(9999, 9999) lineBreakMode:thisLabel.lineBreakMode];
		CGRect thisFrame = CGRectMake( thisX, 0, size.width, size.height );
		thisLabel.frame = thisFrame;
		
		thisX += size.width;
	}
	 */
	 
	
	int thisX = self.frame.size.width;
	
	UILabel *thisLabel;
	int numLabels = self.labels.count;
	for (int i=1; i <= numLabels; i++)
	{	
		thisLabel = [self.labels objectAtIndex:(numLabels - i)];
		CGSize size = [thisLabel.text sizeWithFont:thisLabel.font constrainedToSize:CGSizeMake(9999, 9999) lineBreakMode:thisLabel.lineBreakMode];
		thisX -= size.width;
		CGRect thisFrame = CGRectMake( thisX, 0, size.width, size.height );
		thisLabel.frame = thisFrame;
	}
	
}


- (void)dealloc {
	[labels release];
	labels = nil;
	
	[containerView release];
	containerView = nil;
	
    [super dealloc];
}


@end