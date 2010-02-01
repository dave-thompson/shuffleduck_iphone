//
//  DeckDownloaderQueueItem.h
//  MindEgg
//
//  Created by Dave Thompson on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DeckDownloaderQueueItem : NSObject {
	int userVisibleID;
	BOOL metadataAlreadyExists;
	int iPhoneDeckID;
}

// Initialisers
// Use this initialiser to add decks to the queue that should be downloaded in their entirety
-(id)initWithUserVisibleID:(int)aUserVisibleID;
// Use this initialiser to add decks to the queue that are already partially downloaded and for which only the cards themselves need to be downloaded
// Before calling this initialiser, the deck metadata must already have been entered to the iPhone DB and an iPhone DB DeckID attained
-(id)initWithUserVisibleID:(int)aUserVisibleID iPhoneSpecificID:(int)anIphoneSpecificID;

// getter methods for the userVisible ID and iPhoneDeckID
// Before requesting an iPhoneDeckID, call metadataAlreadyExists to ensure it is YES
-(int)userVisibleID;
-(BOOL)metadataAlreadyExists;
-(int)iPhoneDeckID;

@end
