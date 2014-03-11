//
//  TTViewController.m
//  TeamVision
//
//  Created by ch484-mac6 on 3/11/14.
//  Copyright (c) 2014 Team team. All rights reserved.
//

#import "TTViewController.h"
#import "VideoAnalgesic.h"

@interface TTViewController ()
@property (strong,nonatomic) VideoAnalgesic *videoManager;
@end

@implementation TTViewController

-(VideoAnalgesic *) videoManager
{ if(!_videoManager){

    _videoManager= [VideoAnalgesic captureManager];
    _videoManager.preset = AVCaptureSessionPresetMedium;
    [_videoManager setCameraPosition:AVCaptureDevicePositionBack];

}
return _videoManager;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor=nil;
    
    [self.videoManager setProcessBlock:^(CIImage *cameraImage){
        
        return cameraImage;
    
    
    }];
    

    
    
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(![self.videoManager isRunning])
        [self.videoManager start];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    if([self.videoManager isRunning])
        [self.videoManager stop];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
