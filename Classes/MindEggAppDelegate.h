//
//  MindEggAppDelegate.h
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface MindEggAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet UIWindow *window;
}

@property (nonatomic, retain) UIWindow *window;

- (NSString *)findDatabase;
- (void)connectToDB:(NSString *)dbPath;
- (void)processUserDefaults;

@end