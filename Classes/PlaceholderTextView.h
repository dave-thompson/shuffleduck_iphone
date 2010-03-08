// From http://stackoverflow.com/questions/1328638/placeholder-in-uitextview

//
//  PlaceholderTextView.h
//  MindEgg
//
//  Created by Dave Thompson on 3/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlaceholderTextView : UITextView  {
    NSString *placeholder;
    UIColor *placeholderColor;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
