//
//  LibraryCell.h
//  MindEgg
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideViewController.h"
#import "MultipartLabel.h"

@interface LibraryCell : UITableViewCell {

	// views
	IBOutlet UIView	*miniCardView;
	IBOutlet UIView *mainView;
	// variable text
	IBOutlet MultipartLabel *deckTitle;
	IBOutlet MultipartLabel *leftMultipartLabel;
	IBOutlet MultipartLabel *rightMultipartLabel;
	
	SideViewController *miniCardViewController;
}

@property (nonatomic, retain) UIView *miniCardView;
@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) MultipartLabel *deckTitle;
@property (nonatomic, retain) MultipartLabel *leftMultipartLabel;
@property (nonatomic, retain) MultipartLabel *rightMultipartLabel;

@property (nonatomic, retain) SideViewController *miniCardViewController;

@end
