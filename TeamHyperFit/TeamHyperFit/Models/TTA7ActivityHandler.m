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
    
    [self queryNumberOfStepsFromDay:1 toDay:0 withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           self.numberOfYesterdaySteps = numberOfSteps;
                                           
                                       }];
    
    //! (today = -1) => now
    [self queryNumberOfStepsFromDay:0 toDay:-1 withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           
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


//! if (toDay < 0) then (toDay = Now).

-(void) queryNumberOfStepsFromDay:(NSInteger)fromDay toDay:(NSInteger) toDay withHandler:(stepCallBack) handler
{
    assert(fromDay <= 7);
    assert(fromDay > toDay);
    
    if(fromDay > 7 )
    {
        fromDay = 7;
    }
    if( toDay > fromDay )
    {
        toDay = fromDay;
    }
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);

    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    NSDate *timeFromDay = [NSDate dateWithTimeInterval:-(60*60*24*fromDay) sinceDate:today];
    NSDate *timeToDay = [NSDate dateWithTimeInterval:-(60*60*24*toDay) sinceDate:today];
   
    if ( toDay < 0 ) {
        timeToDay = now;
    }
        
    
    [self.cmStepCounter queryStepCountStartingFrom:timeFromDay to:timeToDay toQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           
                                           handler( numberOfSteps, error);
                                           
                                       }];
    
}

@end


