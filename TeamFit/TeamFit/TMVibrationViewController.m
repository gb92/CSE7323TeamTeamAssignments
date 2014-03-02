//
//  TMVibrationViewController.m
//  TeamFit
//
//  Created by Mark Wang on 3/2/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMVibrationViewController.h"
#import "APLGraphView.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TMVibrationViewController ()

@property (weak, nonatomic) IBOutlet APLGraphView *accelerationGraph;
@property (weak, nonatomic) IBOutlet APLGraphView *rotationRateGraph;

- (IBAction)onStartButtonPressed:(id)sender;
- (IBAction)onStopButtonPressed:(id)sender;


@property (strong, nonatomic) CMMotionManager *cmDeviceMotionManager;

@end

@implementation TMVibrationViewController
{
    BOOL isVibrationStarted;
}

- (IBAction)onStartButtonPressed:(id)sender
{
    [self startVibrate];
}

- (IBAction)onStopButtonPressed:(id)sender
{
    [self stopVibrate];
}

-(CMMotionManager*)cmDeviceMotionManager
{
    if(!_cmDeviceMotionManager){
        _cmDeviceMotionManager = [[CMMotionManager alloc] init];
        
        if(![_cmDeviceMotionManager isDeviceMotionAvailable]){
            _cmDeviceMotionManager = nil;
        }
    }
    return _cmDeviceMotionManager;
    
}


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
	
    isVibrationStarted = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self startMotionUpdates];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.cmDeviceMotionManager stopDeviceMotionUpdates];
}

/*-----------------------------------------------------------------------------*/

-(void) startVibrate
{
    if( !isVibrationStarted )
    {
        isVibrationStarted = YES;
        [self vibe:nil];
    }
}

-(void)stopVibrate
{
    if( isVibrationStarted )
    {
        isVibrationStarted = NO;
    }
}

-(void)vibe:(id)sender
{
    if( isVibrationStarted )
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self performSelector:@selector(vibe:) withObject:self afterDelay:1.0f];
    }
}

-(void) startMotionUpdates
{
    if(self.cmDeviceMotionManager)
    {
        if( ![self.cmDeviceMotionManager isDeviceMotionActive] )
            [self.cmDeviceMotionManager startDeviceMotionUpdates];
        
        NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
        myQueue.maxConcurrentOperationCount = 1;
        [self.cmDeviceMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmDeviceMotionManager
         startDeviceMotionUpdatesToQueue:myQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {

             dispatch_async(dispatch_get_main_queue(),^{
                 [self.accelerationGraph addX:motion.userAcceleration.x
                                    y:motion.userAcceleration.y
                                    z:motion.userAcceleration.z];
                 
                 [self.rotationRateGraph addX:motion.rotationRate.x
                                            y:motion.rotationRate.y
                                            z:motion.rotationRate.z];
                 
             });

         }];
    }
}
@end
