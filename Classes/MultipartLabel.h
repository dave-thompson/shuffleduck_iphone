//
//  MultipartLabel.h
//  MindEgg
//
//  Created by Dave Thompson on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	MultipartLabelLeft,
	MultipartLabelRight,
} MultipartLabelAlignment;

@interface MultipartLabel : UIView {
	
	UIView *containerView;
	NSMutableArray *labels;
	MultipartLabelAlignment alignment;
}

-(void)updateNumberOfLabels:(int)numLabels fontSize:(int)aFontSize alignment:(MultipartLabelAlignment)anAlignment;

-(void)setText:(NSString *)text andColor:(UIColor*)color forLabel:(int)labelNum;
-(void)setText:(NSString *)text forLabel:(int)labelNum;
-(void)setColor:(UIColor*)color forLabel:(int)labelNum;
-(void)setText:(NSString *)text andFont:(UIFont*)font forLabel:(int)labelNum;
-(void)setText:(NSString *)text andFont:(UIFont*)font andColor:(UIColor*)color forLabel:(int)labelNum;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) NSMutableArray *labels;

@end
