//
//  TTCircleImageView.m
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTCircleImageView.h"

@implementation TTCircleImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}


-(void)initialize
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.opaque = NO;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, self.bounds);
    CGContextClip(context);
    //The subclass of UIView has a UIImageview as property
    [_image drawInRect:rect];
}


@end
