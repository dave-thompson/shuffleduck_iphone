//
//  DeckParser.h
//  MindEgg
//
//  Created by Dave Thompson on 1/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DeckParser : NSObject {
	sqlite3 *database;
}

@property (nonatomic, assign) sqlite3 *database;

- (void) getDeckWithUserDeckID:(int)did intoDB:(sqlite3 *)db userProvidedID:(BOOL)upid;
- (void) parseXMLDeck:(NSString *)xmlString withUserID:(int)userVisibleID;
-(void)removeDeckWithUserVisibleID:(int)aUserVisibleID;
- (void) finalizeStatements;
- (void)updateUIForParsingCompletion;

@end