//
//  C4Canvas.m
//  C4iOSDevelopment
//
//  Created by Travis Kirton on 11-10-07.
//  Copyright (c) 2011 mediart. All rights reserved.
//

#import "C4Canvas.h"

@implementation C4Canvas

-(id)init {
    self = [super init];
    if(self) {
        readyToDisplay = NO;
        self.borderWidth = 0.0f;
    }
    return self;
}

-(void)setup {
    [self setOpaque:YES];
    self.backgroundColor = [UIColor whiteColor].CGColor;
    readyToDisplay = YES;
}

-(void)display {
    if(readyToDisplay) [super display]; 
}

/* makes sure the background color is never transparent */
-(void)setBackgroundColor:(CGColorRef)backgroundColor {
    if (CGColorGetAlpha(backgroundColor) == 1.0f)
        [super setBackgroundColor:backgroundColor];
    else 
        [super setBackgroundColor:CGColorCreateCopyWithAlpha(backgroundColor, 1.0f)];
}
@end