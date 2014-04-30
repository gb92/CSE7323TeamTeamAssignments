//
//  TTHeartRateCounter.m
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTHeartRateCounter.h"
@interface TTHeartRateCounter()

@property( strong, nonatomic) NSNumber* currentHeartRate;
@property( nonatomic ) BOOL isStarted;

@end

@implementation TTHeartRateCounter

-(void)start
{
    // Turn on Tourch
    // Video Start
    self.isStarted = YES;
}

-(void)stop
{
    // Turn of Torch
    // turn off video
    self.isStarted = NO;
}

-(NSNumber*)getHeartRate
{
    return self.currentHeartRate;
}

-(BOOL)isStated
{
    return self.isStarted;
}

@end
