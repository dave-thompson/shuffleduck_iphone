//
//  RandomColor.h
//  MindEgg
//
//  Created by Dave Thompson on 5/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface RandomColor : NSObject {

}

+(UIColor *)randomColorWithStateUpdate:(sqlite3 *)databaseForStateUpdate;
+(UIColor *)randomColor;

@end
