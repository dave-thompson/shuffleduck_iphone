//
//  InlineScoreViewController.h
//  MindEgg
//
//  Created by Dave Thompson on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InlineScoreViewController : UIViewController {

	IBOutlet UILabel *topLabel;
	IBOutlet UILabel *bottomLabel;
	
}

-(void)setTopLabelText:(NSString *)labelText;
-(void)setBottomLabelText:(NSString *)labelText;

@end
