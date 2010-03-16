//
//  CustomLabel.m
//  MindEgg
//
//  Created by Dave Thompson on 3/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "CustomLabel.h"

// measurements are based on a font size of 65
#define SIZE_MULTIPLIER (self.font.pointSize / 65)

@implementation CustomLabel

@synthesize verticalAlignment = verticalAlignment_;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.verticalAlignment = VerticalAlignmentMiddle;
    }
    return self;
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
    verticalAlignment_ = verticalAlignment;
    [self setNeedsDisplay];
}


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	
	// Adjust for vertical alignment
    switch (self.verticalAlignment) {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }

	// set width of text rectangle to be the total width of the text to be displayed
	CGSize textSize = [self.text sizeWithFont:self.font];
	int textWidth = textSize.width;
	textRect.size.width = textWidth;
	
	switch(self.textAlignment)
	{
		case UITextAlignmentLeft: // if left align, place on far left
			textRect.origin.x = bounds.origin.x;
			break;
		case UITextAlignmentRight: // if right align, place on far right
			textRect.origin.x = bounds.size.width - textRect.size.width;
			break;			
		case UITextAlignmentCenter:
			// Fall through.
		default:
			textRect.origin.x = (bounds.size.width - textRect.size.width)/2;
	}
	
	return textRect;
}


-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
	//[self.textColor set];
	//[self.text drawAtPoint:requestedRect.origin withFont:self.font];
	
    [super drawTextInRect:actualRect];
	
	// uncomment the following line to aid in debugging - it shows the rectangle in which the text is drawn
	//CGContextStrokeRect(UIGraphicsGetCurrentContext(),actualRect);
}

@end
