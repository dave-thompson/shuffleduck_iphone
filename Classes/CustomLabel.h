//
//  CustomLabel.h
//  ShuffleDuck
//
//  Created by Dave Thompson on 3/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;


@interface CustomLabel : UILabel {
@private
    VerticalAlignment verticalAlignment_;

}

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end

