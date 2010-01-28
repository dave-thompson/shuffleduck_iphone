//
//  AllDecksViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface DownloadViewController : UIViewController {
	IBOutlet UITextField *idTextField;
	sqlite3 *database;
}

@property (nonatomic, assign) sqlite3 *database;

- (IBAction) downloadButtonClicked:(id)sender;

@end