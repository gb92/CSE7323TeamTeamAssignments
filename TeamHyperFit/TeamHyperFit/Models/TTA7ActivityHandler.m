//
//  TTA7ActivityHandler.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/6/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTA7ActivityHandler.h"
#import <CoreMotion/CoreMotion.h>

@interface TTA7ActivityHandler()

@property (strong,nonatomic) CMStepCounter *cmStepCounter;

@end

@implementation TTA7ActivityHandler


-(CMStepCounter*)cmStepCounter{
    if(!_cmStepCounter){
        if([CMStepCounter isStepCountingAvailable]){
            _cmStepCounter = [[CMStepCounter alloc] init];
        }
    }
    return _cmStepCounter;
}

-(id)init
{
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
    NSLog(@"timeToRemove: %ld", timeToRemove);
    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    NSDate *yesterday = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:today];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-YYYY hh:mm:ss"];
    NSLog(@"NSDate today: %@",[formatter stringFromDate:today]);
    NSLog(@"NSDate yesterday: %@", [formatter stringFromDate:yesterday]);
    NSLog(@"NSDate now: %@", [formatter stringFromDate:now]);
    
    [self.cmStepCounter queryStepCountStartingFrom:yesterday to:today toQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           self.numberOfYesterdaySteps = numberOfSteps;
                                           
                                       }];
    
    
    [self.cmStepCounter queryStepCountStartingFrom:today to:now toQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           
                                           self.numberOfStepsSinceMorningUntilOpenApp = numberOfSteps;
                                           self.numberOfSteps = numberOfSteps;
                                           
                                       }];
    
    [self.cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                               updateOn:1
                                            withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                                if(!error){
                                                    
                                                    self.numberOfSteps = self.numberOfStepsSinceMorningUntilOpenApp + numberOfSteps;
                                                    
                                                    NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys: @(self.numberOfSteps), @"steps", nil];
                                                    
                                                    [[NSNotificationCenter defaultCenter]
                                                     postNotificationName:@"stepsUpdate"
                                                     object:data];

                                                }
                                            }];
    
    return self;
}


@end


