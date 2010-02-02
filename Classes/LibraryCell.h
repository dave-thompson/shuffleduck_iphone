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
	IBOutlet MultipartLabel *leftMultipartLabel;
	IBOutlet MultipartLabel *rightMultipartLabel;
	IBOutlet UILabel *titleLabel;
	
	SideViewController *miniCardViewController;
}

- (void)setFullyDownloaded:(BOOL)isFullyDownloaded withTitle:(NSString *)theTitle numKnownCards:(int)theNumKnownCards numUnknownCards:(int)theNumUnknownCards;

@property (nonatomic, retain) UIView *miniCardView;
@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) MultipartLabel *leftMultipartLabel;
@property (nonatomic, retain) MultipartLabel *rightMultipartLabel;
@property (nonatomic, retain) UILabel *titleLabel;

@property (nonatomic, retain) SideViewController *miniCardViewController;

@end
