//
//  DownloadViewController.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface DownloadViewController : UIViewController {
	IBOutlet UITextField *idTextField;
}

+ (DownloadViewController *)sharedInstance;

- (IBAction) downloadButtonClicked:(id)sender;

- (int)deckID;
- (void)setDeckID:(int)deckID;

@end
