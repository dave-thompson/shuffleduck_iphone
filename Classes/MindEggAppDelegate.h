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
	//UITabBarController *tabBarController;
	NSString *dbPath;
	sqlite3 *database;
}

@property (nonatomic, retain) UIWindow *window;

- (void) copyDatabaseIfNeeded;
- (void) connectToDBAndRetrieveState;
- (NSString *)getDBPath;

@end

