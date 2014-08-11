//
//  BlockView.m
//  Breakout
//
//  Created by ETC ComputerLand on 8/1/14.
//  Copyright (c) 2014 cmeats. All rights reserved.
//

#import "BlockView.h"

@implementation BlockView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dificulty = 0;
        self.colors = [[NSArray alloc] initWithObjects:
                       [UIColor grayColor],
                       [UIColor yellowColor],
                       [UIColor redColor],
                       [UIColor greenColor],
                       nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dificulty = 0;
        self.colors = [[NSArray alloc] initWithObjects:
                       [UIColor grayColor],
                       [UIColor yellowColor],
                       [UIColor redColor],
                       [UIColor greenColor],
                       nil];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
