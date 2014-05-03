//
//  TTPositionToBoundsDynamicItem.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/2/14.
//  Inspired by Apple UI Dynamic Catalog example.
//  Copyright (c) 2014 SMU. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@protocol ResizableDynamicItem <UIDynamicItem>
@property (nonatomic, readwrite) CGRect bounds;
@property (nonatomic, readwrite) CGRect defaultBounds;
@end

@interface TTPositionToBoundsDynamicItem : NSObject <UIDynamicItem>

- (instancetype)initWithTarget:(id<ResizableDynamicItem>)target;

@end
