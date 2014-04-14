//
//  TTMotionCaptureViewController.m
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTMotionCaptureViewController.h"

@interface TTMotionCaptureViewController ()


@end

@implementation TTMotionCaptureViewController
{
dispatch_queue_t motionCaptureQueue;
    bool bCollecting;
}




- (IBAction)onCapturingButtonUp:(UIButton *)sender {
    bCollecting=false;
    }


- (IBAction)onCapturedButtonDown:(id)sender {
    
    bCollecting= true;
    
    dispatch_async(motionCaptureQueue, ^{
        
        
        while(bCollecting)
            
        {printf("do some work here.\n");}
        
        
        
    });
    

    NSLog(@"Second One");
}
- (IBAction)onCapturingButtonHold:(UIButton *)sender {
    NSLog(@"I work");
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
    
    
    
    
   motionCaptureQueue = dispatch_queue_create("edu.smu.TeamTeam.MotionCapture", NULL);
      
    

    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
