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

	// views
	IBOutlet UIView	*miniCardView;
	IBOutlet UIView *mainView;
	// variable text
	IBOutlet UILabel *deckTitle;
	IBOutlet UILabel *known;
	IBOutlet UILabel *unknown;
	
	// static text
	IBOutlet UILabel *unknownDescriptionLabel;
	IBOutlet UILabel *knownDescriptionLabel;	
	
	SideViewController *miniCardViewController;
}

@property (nonatomic, retain) UIView *miniCardView;
@property (nonatomic, retain) UIView *mainView;

@property (nonatomic, retain) UILabel *deckTitle;
@property (nonatomic, retain) UILabel *known;
@property (nonatomic, retain) UILabel *unknown;

@property (nonatomic, retain) UILabel *unknownDescriptionLabel;
@property (nonatomic, retain) UILabel *knownDescriptionLabel;

@property (nonatomic, retain) SideViewController *miniCardViewController;

@end
