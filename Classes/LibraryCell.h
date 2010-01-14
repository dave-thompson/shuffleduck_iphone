//
//  LibraryCell.h
//  MindEgg
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideViewController.h"

@interface LibraryCell : UITableViewCell {

	IBOutlet UILabel *deckTitle;
	IBOutlet UIView	*miniCardView;
	IBOutlet UILabel *subTitle;
	SideViewController *miniCardViewController;
}

@property (nonatomic, retain) UILabel *deckTitle;
@property (nonatomic, retain) UIView *miniCardView;
@property (nonatomic, retain) UILabel *subTitle;
@property (nonatomic, retain) SideViewController *miniCardViewController;

@end
