//
//  DownloadViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 5/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface DownloadViewController : UIViewController {
	IBOutlet UITextField *idTextField;
}

- (IBAction) downloadButtonClicked:(id)sender;

@end
