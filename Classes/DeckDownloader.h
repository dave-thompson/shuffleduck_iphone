//
//  DeckDownloader.h
//  MindEgg
//
//  Created by Dave Thompson on 1/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//
//	DeckParser is designed to be used one time, to download a deck with a specified User Visible Deck ID
//	Do not use a single instance of DeckParser to download more than a single deck


#import <Foundation/Foundation.h>
#import "sqlite3.h"

//static int count;

@interface DeckDownloader : NSObject {
}

-(id) initWithDeckID:(int)did;

-(void) parseXMLDeck:(NSString *)xmlString withUserID:(int)userVisibleID;

-(void) updateUIForParsingCompletion;
-(void) removeDeckWithUserVisibleID:(int)aUserVisibleID;

- (void) finalizeStatements;

@end