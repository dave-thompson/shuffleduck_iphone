//
//  LibraryCell.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideViewController.h"
#import "MultipartLabel.h"

@interface LibraryCell : UITableViewCell {

	// views
	IBOutlet UIView	*sideView;
	IBOutlet UIView *mainView;
	// variable text
	IBOutlet UILabel *remainLabel;
	IBOutlet UILabel *titleLabel;
	
	SideViewController *sideViewController;
}

- (void)setFullyDownloaded:(BOOL)isFullyDownloaded withTitle:(NSString *)theTitle numKnownCards:(int)theNumKnownCards numUnknownCards:(int)theNumUnknownCards;

@property (nonatomic, retain) UIView *sideView;
@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *remainLabel;

@end
