//
//  TTHeartRateGraph.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/12/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface TTHeartRateGraph : UIView

@property (strong, nonatomic) NSArray* data;
@property (strong, nonatomic) NSArray* dataLabel;

@property (strong, nonatomic) NSNumber* numberOfColumn;

@property (nonatomic) BOOL isShowPointNumber;

@end
