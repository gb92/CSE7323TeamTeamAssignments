//
//  TTA7ActivityHandler.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/6/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

//! This class use Notification Center.

@interface TTA7ActivityHandler : NSObject

@property (nonatomic) NSInteger numberOfSteps;
@property (nonatomic) NSInteger numberOfStepsSinceMorningUntilOpenApp;
@property (nonatomic) NSInteger numberOfYesterdaySteps;

@end
