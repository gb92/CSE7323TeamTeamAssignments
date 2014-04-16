//
//  TTMotionCaptureViewController.m
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTMotionCaptureViewController.h"
#import <CoreMotion/CoreMotion.h>

#import "TTGesture.h"
#import "RingBuffer.h"

@interface TTMotionCaptureViewController ()<UIAlertViewDelegate>

@property (strong,nonatomic) CMMotionManager *cmMotionManager;
@property (strong, nonatomic ) RingBuffer *ringBuffer;

@end

@implementation TTMotionCaptureViewController
{
    dispatch_queue_t motionCaptureQueue;
    bool bCollecting;
    int count;
}


-(RingBuffer*)ringBuffer
{
    if(!_ringBuffer)
    {
        _ringBuffer = [[RingBuffer alloc] init];
    }
    
    return _ringBuffer;
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
            
             [self.ringBuffer addNewData:motion.userAcceleration.x withY:motion.userAcceleration.y withZ:motion.userAcceleration.z ];
             
             NSLog(@"x : %f", motion.userAcceleration.x );
             
         }];
    }
}

-(void)activate
{
    [self startMotionUpdates];
}

-(void)deactivate
{
    if ([self.cmMotionManager isDeviceMotionActive]) {
        [self.cmMotionManager stopDeviceMotionUpdates];
    }
}

- (IBAction)onCapturingButtonUp:(UIButton *)sender
{
    
    [self deactivate];
    
//    bCollecting=false;
	
//	UIAlertView *alert = [UIAlertView new];
//	alert.title = @"Motion Name";
//	alert.message = @"Please enter the Gesture's Name:";
//	alert.delegate = self;
//	[alert addButtonWithTitle:@"OK"];
//	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//	[alert show];
}


- (IBAction)onCapturedButtonDown:(id)sender {
  
    
    [self activate];
    
//    bCollecting= true;
    
//    dispatch_async(motionCaptureQueue, ^{
//        
//        
//        while(bCollecting)
//        {
//             NSLog(@"Second One %d", count);
//		}
//        
//    });
    
}

- (IBAction)onCapturingButtonHold:(UIButton *)sender
{
    NSLog(@"I work");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

   motionCaptureQueue = dispatch_queue_create("edu.smu.TeamTeam.MotionCapture", NULL);
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self deactivate];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UITextField *gestureTextField = [alertView textFieldAtIndex:0];
	TTGesture *capturedGesture = [TTGesture new];
	capturedGesture.name = gestureTextField.text;
	
	if (self.delegate)
	{
		[self.delegate didCaptureNewMotion:capturedGesture];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
