//
//  ShuffleDuckUtilities.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ShuffleDuckUtilities : NSObject {

}

+ (void)shuffleDuckErrorAlertWithMessage:(NSString *)aMessage;
+ (void)runSQLUpdate:(NSString *)sqlString;
+(int)getIntUsingSQL:(NSString *)sqlString;
+(NSString *)getStringUsingSQL:(NSString *)sqlString;

@end
