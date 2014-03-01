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
@property (strong,nonatomic) CMStepCounter *cmStepCounter;
@property (strong,nonatomic) NSNumber *dailyStepGoal;

@property (strong, nonatomic) NSString *currentActivityLabelText;

@property long numberOfStepsToday;
@property long numberOfSteps;
@end

@implementation Assignment3ViewController


-(NSString *) currentActivityLabelText
{
    if(!_currentActivityLabelText){
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
        [self.dailyStepGoalTextField setText:[NSString stringWithFormat:@"%ld", [_dailyStepGoal longValue]]];
    }
    return _dailyStepGoal;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.dailyStepGoalTextField.delegate=self;
    
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
                                            self.stepsYesterdayLabel.text = [NSString stringWithFormat:@"Steps Yesterday: %ld",(long)numberOfSteps];
                                        
                                       }];
    
    [self.cmStepCounter queryStepCountStartingFrom:today to:now toQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           self.numberOfStepsToday=numberOfSteps;
                                           [self.stepsTodayLabel setText:[NSString stringWithFormat:@"Steps Today: %ld",(long)numberOfSteps]];
                                           [self.stepsToDailyGoalProgressBar setProgress: (numberOfSteps)/[self.dailyStepGoal floatValue]];
                                       }];
    
    
    
    [self.cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                               updateOn:1
                                            withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                                if(!error){
                                                    
                                                    self.numberOfSteps=(long)numberOfSteps;
                                                    
                                                    [self.stepsToDailyGoalProgressBar setProgress: (self.numberOfStepsToday+numberOfSteps)/[self.dailyStepGoal floatValue]];
                                                    self.stepsTodayLabel.text = [NSString stringWithFormat:@"Steps Today: %ld",(long)(self.numberOfStepsToday+numberOfSteps)];
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

- (IBAction)updateDailyGoal:(id)sender {
    UITextField *dailyGoalTextField=(UITextField*)sender;
    
    self.dailyStepGoal=[[NSNumber alloc] initWithInteger:dailyGoalTextField.text.integerValue];
    
}



- (IBAction)backgroundTap:(id)sender {
    [self.dailyStepGoalTextField resignFirstResponder];
    
    self.dailyStepGoal=[[NSNumber alloc] initWithInteger:self.dailyStepGoalTextField.text.integerValue];
    
    [self.stepsToDailyGoalProgressBar setProgress: (self.numberOfStepsToday+self.numberOfSteps)/[self.dailyStepGoal floatValue]];
}

@end
