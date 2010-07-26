//
//  CardViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideViewController.h"
#import "sqlite3.h"

@interface CardViewController : UIViewController {

	SideViewController *sideAViewController;
	SideViewController *sideBViewController;
	
	int DBDeckID;

	BOOL animationInProgress; // YES when there are animations still in progress - do not request changes to the card view if this is YES
}

typedef enum {
	CardViewAnimationReveal,      // instantly switch side A and side B
	CardViewAnimationFlip,        // switch side A and B with a flip animation
	CardViewAnimationSlideLeft,   // switch side A and B with a slide to the left
	CardViewAnimationSlideRight   // switch side A and B with a slide to the right
} CardViewAnimation;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(UIView *)visibleView;
-(void)revealHiddenSide:(CardViewAnimation)animationStyle;
-(void)loadFrontSideWithDBSideID:(int)sideID;
-(void)loadBackSideWithDBSideID:(int)sideID;
-(void)setFrontSideBlank;
-(void)setBackSideBlank;

@property (nonatomic, retain) SideViewController *sideAViewController;
@property (nonatomic, retain) SideViewController *sideBViewController;
@property (nonatomic, assign) int DBDeckID;
@property (nonatomic, assign) BOOL animationInProgress;

@end
