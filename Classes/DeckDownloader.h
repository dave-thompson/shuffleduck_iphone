//
//  DeckDownloader.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 1/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//
// DeckDownloader provides a singleton instance which may be used to download decks through the (void)downloadDeckID:(int)aDeckID method.
// Objects should call this method using [[DeckDownloader sharedInstance] downloadDeckID:30009999];
// DeckDownloader operates in the background and manages a queue of downloads if necessary. Simply call this function and forget about it.

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DeckDownloader : NSObject {
}

+ (DeckDownloader *)sharedInstance;

+ (BOOL)downloadIsInProgress;
+ (BOOL)areBrokenDownloads;

-(void)downloadDeckID:(int)aDeckID;
-(void)completeDownloadOfDeckID:(int)userVisibleID withIPhoneDeckID:(int)deckID;
-(void)resumeBrokenDownloadswithUserRequested:(BOOL)userRequested;

-(void)sendMetadataRequestForUserVisibleDeckID:(int)aUserVisibleID;
+ (int)insertNewDeckMetadataToDBWithUserVisibleID:(int)aUserVisibleID title:(NSString *)aTitle author:(NSString *)anAuthor;

-(void)sendFullDeckRequestForUserVisibleDeckID:(int)aUserVisibleID iPhoneDeckID:(int)anIphoneDeckID;


-(void) parseXMLDeck:(NSString *)xmlString;

-(void)cleanPartiallyDownloadedDeckInDBUsingDeckID:(int)aDeckID;
- (void)completeDownloadAfterSuccess:(BOOL)success;

@end