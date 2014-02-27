//
//  Assignment3ViewController.m
//  Assignment3
//
//  Created by ch484-mac7 on 2/25/14.
//  Copyright (c) 2014 ch484-mac7. All rights reserved.
//

#import "Assignment3ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface Assignment3ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepsTodayLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsYesterdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentActivityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dailyStepGoalLabel;
@property (weak, nonatomic) IBOutlet UITextField *dailyStepGoalTextField;
@property (weak, nonatomic) IBOutlet UILabel *stepsToDailyGoalLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *stepsToDailyGoalProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *stairsClimbedLabel;

@property (strong,nonatomic) CMMotionActivityManager *cmActivityManager;
@property (strong,nonatomic) CMDeviceMotion *cmDiviceMotionManager;
@property (strong,nonatomic) CMStepCounter *cmStepCounter;
@property (strong,nonatomic) NSNumber *dailyStepGoal;

@property (strong, nonatomic) NSString *currentActivityLabelText;

@property (strong,nonatomic) CMMotionManager *cmMotionManager;

@end

@implementation Assignment3ViewController
{
    NSInteger stairStep;
    BOOL bMovingUp;
}


-(CMMotionManager*)cmMotionManager{
    if(!_cmMotionManager){
        _cmMotionManager = [[CMMotionManager alloc] init];
        
        if(![_cmMotionManager isDeviceMotionAvailable]){
            _cmMotionManager = nil;
        }
    }
    return _cmMotionManager;
    
}

-(NSString *) currentActivityLabelText
{
    if(!_currentActivityLabelText)
    {
        _currentActivityLabelText=@"Current Activity: %@";
    }
    
    return _currentActivityLabelText;
}

-(CMMotionActivityManager*)cmActivityManager{
    if(!_cmActivityManager){
        if([CMMotionActivityManager isActivityAvailable])
            _cmActivityManager = [[CMMotionActivityManager alloc]init];
    }
    return _cmActivityManager;
}

-(CMStepCounter*)cmStepCounter{
    if(!_cmStepCounter){
        if([CMStepCounter isStepCountingAvailable]){
            _cmStepCounter = [[CMStepCounter alloc] init];
        }
    }
    return _cmStepCounter;
}

-(NSNumber*)dailyStepGoal{
    if(!_dailyStepGoal){
        _dailyStepGoal = @(100);
    }
    return _dailyStepGoal;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [self.cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                               updateOn:1
                                            withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                                if(!error){
                                                    [self.stepsToDailyGoalProgressBar setProgress: numberOfSteps/[self.dailyStepGoal floatValue]];
                                                    self.stepsTodayLabel.text = [NSString stringWithFormat:@"Steps Today: %ld",(long)numberOfSteps];
                                                }
                                            }];
    
    [self.cmActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                    withHandler:^(CMMotionActivity *activity) {
                                        if(activity.running){
                                            self.currentActivityLabel.text = [NSString stringWithFormat:self.currentActivityLabelText,@"Running"];
                                        }else if (activity.walking){
                                            self.currentActivityLabel.text = [NSString stringWithFormat:self.currentActivityLabelText,@"Walking"];
                                        }else if (activity.automotive){
                                            self.currentActivityLabel.text = [NSString stringWithFormat:self.currentActivityLabelText,@"In Car"];
                                        }else if (activity.stationary){
                                            [self.currentActivityLabel setText:[NSString stringWithFormat:self.currentActivityLabelText,@"Doing Nothing"]];
                                        }
                                    }];
//
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) startMotionUpdates{
    
    static unsigned int stairCountingActiveDuration = 1000;
    static unsigned int currentTime = 0;
    
    if(self.cmMotionManager){
        NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
        myQueue.maxConcurrentOperationCount = 1;
        
        [self.cmMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmMotionManager
         startDeviceMotionUpdatesToQueue:myQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {
             
             float dotProduct =
             motion.gravity.x*motion.userAcceleration.x +
             motion.gravity.y*motion.userAcceleration.y +
             motion.gravity.z*motion.userAcceleration.z;
             
             if (dotProduct < -0.2f)
             {
                 //@TODO Start queary stair time.
                 NSLog(@"The phone is moving up! %ld", stairStep);
                 
                 bMovingUp = YES;
                 
             }
             else
             {
                 if( currentTime > stairCountingActiveDuration )
                 {
                     //@TODO End Query stair time.
                     bMovingUp = NO;
                 }
             }
             
         }];
    }
}

@end
