//
//  TMStairViewController.m
//  TeamFit
//
//  Created by Mark Wang on 2/28/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMStairViewController.h"
#import "TMUIStairImageView.h"
#import "TMStairSettingViewController.h"

#import <CoreMotion/CoreMotion.h>


@interface TMStairViewController ()
@property (weak, nonatomic) IBOutlet TMUIStairImageView *stairIndicator;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
- (IBAction)onPlayButtonPressed:(id)sender;
- (IBAction)onResetButtonPressed:(id)sender;

@property (strong,nonatomic) CMStepCounter *cmStepCounter;
@property (strong,nonatomic) CMMotionManager *cmMotionManager;
@property (strong, nonatomic) NSDate *timeStartStairs;
@property (strong, nonatomic) NSDate *timeStopStairs;

@property (nonatomic) float motionThreshold;
@end

@implementation TMStairViewController
{
    
    NSInteger stairStep;
    BOOL bMovingUp;
}

-(CMMotionManager*)cmMotionManager
{
    if(!_cmMotionManager){
        _cmMotionManager = [[CMMotionManager alloc] init];
        
        if(![_cmMotionManager isDeviceMotionAvailable]){
            _cmMotionManager = nil;
        }
    }
    return _cmMotionManager;
    
}

-(CMStepCounter*)cmStepCounter{
    if(!_cmStepCounter){
        if([CMStepCounter isStepCountingAvailable]){
            _cmStepCounter = [[CMStepCounter alloc] init];
        }
    }
    return _cmStepCounter;
}


/*-------------------------------------------------*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.isActivated = NO;
    
    self.motionThreshold = -0.35f;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateUI];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self deactivate];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toSettingView"])
    {
        TMStairSettingViewController* settingView = segue.destinationViewController;
        [settingView setThresholdValue:self.motionThreshold];
        settingView.delegate = self;
    }
}

- (IBAction)onPlayButtonPressed:(id)sender
{
    if( !self.isActivated )
    {
        [self activate];
    }
    else
    {
        [self deactivate];
    }
}

- (IBAction)onResetButtonPressed:(id)sender
{
    [self reset];
}

-(void)TMStairSettingViewControllerSetButtonPressed:(TMStairSettingViewController *)controller withThresholdValue:(float)thresholdValue
{
    self.motionThreshold = thresholdValue;
    NSLog(@"New Threshold is %f", self.motionThreshold);
}

-(void)TMStairSettingViewControllerCancelButtonPressed:(TMStairSettingViewController *)controller
{
    // Do nothing for now.
}

/*----------------------------------------------------------------*/
-(void) startMotionUpdates{
    
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
             
             float dotProduct =
             motion.gravity.x*motion.userAcceleration.x +
             motion.gravity.y*motion.userAcceleration.y +
             motion.gravity.z*motion.userAcceleration.z;
             
             if (dotProduct < self.motionThreshold)
             {
                 if( !bMovingUp )
                     bMovingUp = YES;

             }
             else
             {
                 if (bMovingUp)
                 {
                     bMovingUp = NO;
                     stairStep ++;
                     
                     dispatch_async(dispatch_get_main_queue(),^{
                         [self updateUI];
                     });
                 }

             }
             
         }];
    }
}

/*----------------------------------------------------------------*/

-(void)reset
{
    stairStep = 0;
    
    if( self.isActivated )
        [self deactivate];
    
    [self updateUI];
}

-(void)activate
{
    [self startMotionUpdates];
    
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.stairIndicator activate];
    self.isActivated = YES;
}

-(void)deactivate
{
    if ([self.cmMotionManager isDeviceMotionActive]) {
        [self.cmMotionManager stopDeviceMotionUpdates];
    }
    
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    
    [self.stairIndicator deactivate];
    self.isActivated = NO;
}

-(void)updateUI
{
    [self.stepLabel setText:[NSString stringWithFormat:@"%ld",(long)stairStep]];
}

@end
