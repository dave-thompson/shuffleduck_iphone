//
//  SideViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 6/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface SideViewController : UIViewController {

	float _sizeMultiplier;
	
}

-(void)clearSide;
-(void)replaceSideWithSideID:(int)sideID FromDB:(sqlite3 *)sourceDatabase;
-(void)setCustomSizeByWidth:(uint)widthInPixels;

@end
