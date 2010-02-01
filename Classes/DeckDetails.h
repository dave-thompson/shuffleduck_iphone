//
//  DeckDetails.h
//  MindEgg
//
//  Created by Dave Thompson on 6/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DeckDetails : NSObject {
	int deckID;
	int firstSideID;
	NSString *title;
	int numCards;
	int numKnownCards;
	BOOL fullyDownloaded;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int deckID;
@property (nonatomic, assign) int firstSideID;
@property (nonatomic, assign) int numCards;
@property (nonatomic, assign) int numKnownCards;
@property (nonatomic, assign) BOOL fullyDownloaded;

-(id)initWithID:(int)aDeckID firstSideID:(int)aFirstSideID title:(NSString *)aTitle numCards:(int)theNumCards numKnownCards:(int)theNumKnownCards fullyDownloaded:(BOOL)downloaded;

@end
