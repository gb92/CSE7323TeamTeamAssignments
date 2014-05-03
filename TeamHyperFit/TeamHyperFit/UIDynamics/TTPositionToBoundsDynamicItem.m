//
//  TTPositionToBoundsDynamicItem.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/2/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTPositionToBoundsDynamicItem.h"

@interface TTPositionToBoundsDynamicItem ()
@property (nonatomic, strong) id<ResizableDynamicItem> target;
@end


@implementation TTPositionToBoundsDynamicItem


- (instancetype)initWithTarget:(id<ResizableDynamicItem>)target
{
    self = [super init];
    if (self)
    {
        _target = target;
    }
    return self;
}

#pragma mark -
#pragma mark UIDynamicItem


- (CGRect)bounds
{
    return self.target.bounds;
}

- (CGPoint)center
{
    return CGPointMake(self.target.bounds.size.width, self.target.bounds.size.height);
}

- (void)setCenter:(CGPoint)center
{
    self.target.bounds = CGRectMake(0, 0, center.x, center.y);
}

- (CGAffineTransform)transform
{
    return self.target.transform;
}

- (void)setTransform:(CGAffineTransform)transform
{
    self.target.transform = transform;
}

@end