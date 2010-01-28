//
//  MultipartLabel.h
//  MindEgg
//
//  Created by Dave Thompson on 1/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MultipartLabel : UIView {

	UIView *containerView;
	NSMutableArray *labels;
	
}

-(void)updateNumberOfLabels:(int)numLabels;
-(void)setText:(NSString *)text andColor:(UIColor*)color forLabel:(int)labelNum;
-(void)setText:(NSString *)text forLabel:(int)labelNum;
-(void)setText:(NSString *)text andFont:(UIFont*)font forLabel:(int)labelNum;
-(void)setText:(NSString *)text andFont:(UIFont*)font andColor:(UIColor*)color forLabel:(int)labelNum;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) NSMutableArray *labels;

@end
