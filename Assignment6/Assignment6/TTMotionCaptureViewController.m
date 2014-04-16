//
//  TTMotionCaptureViewController.m
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTMotionCaptureViewController.h"
#import "TTGesture.h"

@interface TTMotionCaptureViewController ()<UIAlertViewDelegate>

@end

@implementation TTMotionCaptureViewController
{
    dispatch_queue_t motionCaptureQueue;
    bool bCollecting;
    int count;
}




- (IBAction)onCapturingButtonUp:(UIButton *)sender
{
    bCollecting=false;
	
	UIAlertView *alert = [UIAlertView new];
	alert.title = @"Motion Name";
	alert.message = @"Please enter the Gesture's Name:";
	alert.delegate = self;
	[alert addButtonWithTitle:@"OK"];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}


- (IBAction)onCapturedButtonDown:(id)sender {
    
    bCollecting= true;
    count = 0;
    
    dispatch_async(motionCaptureQueue, ^{
        
        
        while(bCollecting)
        {
             NSLog(@"Second One %d", count);
            count++;
		}
        
        
    });
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
