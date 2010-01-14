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
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) int deckID;
@property (nonatomic, assign) int firstSideID;
@property (nonatomic, assign) int numCards;
@property (nonatomic, assign) int numKnownCards;

-(id)initWithID:(int)initID firstSideID:(int)initFirstSideID title:(NSString *)initTitle numCards:(int)numberCards numKnownCards:(int)numberKnownCards;

@end
