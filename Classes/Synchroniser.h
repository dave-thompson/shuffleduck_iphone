//
//  DeckDownloader.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 1/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//
// Synchroniser provides a singleton instance which may be used to synchronise decks through the (void)synchronise method.
// Objects should call this method using [[Synchroniser sharedInstance] synchronise];
// Synchroniser operates in the background. Simply call this function and forget about it.

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface Synchroniser : NSObject {
}

+ (Synchroniser *)sharedInstance;

-(void) synchronise;
- (void) credentialsEntered;
- (void) handleSyncFailure;

@end