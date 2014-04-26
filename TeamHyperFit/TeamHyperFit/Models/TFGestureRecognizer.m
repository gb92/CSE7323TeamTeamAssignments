//
//  TFGestureRecognizer.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TFGestureRecognizer.h"
#import <CoreMotion/CoreMotion.h>

@interface TFGestureRecognizer()

@property (strong, nonatomic)  CMMotionManager *cmMotionManager;


@end

@implementation TFGestureRecognizer
{
    dispatch_queue_t motionCaptureQueue;
}


-(CMMotionManager *) cmMotionManager
{
    if(_cmMotionManager == nil)
    {
        _cmMotionManager = [[CMMotionManager alloc] init];
        
        if(![_cmMotionManager isDeviceMotionAvailable]){
            _cmMotionManager = nil;
        }

    }
    return _cmMotionManager;
}


-(void) startGestureCapture
{
    if(motionCaptureQueue == nil)
        motionCaptureQueue=dispatch_queue_create("edu.smu.TeamTeam.MotionCapture", NULL);
    
    if(self.cmMotionManager)
    {
        if (![self.cmMotionManager isDeviceMotionActive]) {
            [self.cmMotionManager startDeviceMotionUpdates];
        }
        
        NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
        myQueue.maxConcurrentOperationCount = 1;
        
        [self.cmMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmMotionManager
         startDeviceMotionUpdatesToQueue:myQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {
             
//             [self addNewData:motion.userAcceleration.x
//                                   withY:motion.userAcceleration.y
//                                   withZ:motion.userAcceleration.z ];
             
         }];
    }
}

-(void) stopGestureCapture
{
    [self.cmMotionManager stopDeviceMotionUpdates];
}

@end
