//
//  ManualPage.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualPageViewController : UIViewController {

	IBOutlet UIWebView *webView;
	NSString *filePath;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, copy) NSString *filePath;

@end
