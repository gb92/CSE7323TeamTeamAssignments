//
//  TMHeartbeatview.m
//  TeamFit
//
//  Created by ch484-mac6 on 3/12/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMHeartbeatViewController.h"
#import <opencv2/highgui/cap_ios.h>
#import "APLGraphView.h"
#import <numeric>

#import "TMHeartBeatCounter.h"

#define LogCall() NSLog(@"%d %s", __LINE__, __func__)

using namespace cv;
using namespace TeamTeam;

static const int kFramesPerSec = 24;
static const int kSampleSecond = 5;

@interface TMHeartbeatViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet APLGraphView *heartBeatGraphView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCamera* videoCamera;

@end

@implementation TMHeartbeatViewController
{
#ifdef __cplusplus
    TMHeartRateCounter *heartBeatCounter;
#endif
}


- (IBAction)ToggleTorch:(UISwitch *)sender
{
	
    if(self.videoCamera.defaultAVCaptureDevicePosition==AVCaptureDevicePositionBack){
        
        if([sender isOn])
        {
            [self setTorchOn:YES];
        }
        else
        {
            [self setTorchOn:NO];
        }
        
    }
}

-(void)setTorchOn: (BOOL) onoff
{
	LogCall(); // Changed:
	
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:onoff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

std::vector<float> maximumValueList;
std::vector<float> meanOfRedValues;

#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    
    Mat image_copy;
    //============================================
    // get average pixel intensity
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    Scalar avgPixelIntensity = cv::mean( image_copy );
    
    heartBeatCounter->setMeanOfPixelValue( avgPixelIntensity[2], avgPixelIntensity[1], avgPixelIntensity[0] );
    
    //------------------------
    
    float heartRate = heartBeatCounter->getHeartRate();
    
    maximumValueList = heartBeatCounter->getMaximumValueList();
    meanOfRedValues = heartBeatCounter->getMeanOfRedValue();
    
    if( meanOfRedValues.size() > 0 && maximumValueList.size() > 0)
    {
        //-----------------------
        std::vector<float>drawingBuffer;
        drawingBuffer.assign(meanOfRedValues.begin(), meanOfRedValues.end());
        
        std::vector<float>drawingMaximarBuffer;
        drawingMaximarBuffer.assign(maximumValueList.begin(), maximumValueList.end());
        
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self drawGraph:drawingBuffer withMaximarList:drawingMaximarBuffer];
        });
    
    }
    
    // Display color values and heartrate onto the image.
    char text[50];
    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f, H: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2], heartRate * 60 / kSampleSecond );
    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
}

#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(CvVideoCamera *)videoCamera
{
    if(!_videoCamera)
    {
        _videoCamera= [[CvVideoCamera alloc ] initWithParentView:self.imageView];
        _videoCamera.delegate = self;
        _videoCamera.defaultAVCaptureDevicePosition=AVCaptureDevicePositionBack;
        _videoCamera.defaultAVCaptureSessionPreset=AVCaptureSessionPreset352x288;
        _videoCamera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationLandscapeLeft;
        _videoCamera.defaultFPS = kFramesPerSec;
        _videoCamera.grayscaleMode = NO;
        
    }
    return  _videoCamera;
}

#pragma mark - Overload functions

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    if( heartBeatCounter )
        delete heartBeatCounter;
}


-(void)viewDidAppear:(BOOL)animated
{
    
	[super viewDidAppear:animated];
    
    if( !heartBeatCounter )
        heartBeatCounter = new TMHeartRateCounter();
    
	[self.videoCamera start];
    
    [self setTorchOn:YES];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    [self.videoCamera stop];
    [super viewWillDisappear:animated];
    
}


-(void) drawGraph:( std::vector<float> ) data withMaximarList:(std::vector<float>) maxList
{
    static const double kTimePerSec = (1.0 / kFramesPerSec);
    
    for( int i = 0; i<data.size(); i++ )
    {
        CIVector *vec = [CIVector vectorWithX:data[i] Y:maxList[i] Z:0];
		[NSTimer scheduledTimerWithTimeInterval:i * kTimePerSec target:self selector:@selector(sendPlotValueToGraphToDraw:) userInfo:vec repeats:NO];
    }
    
}

//! Plot graph to Graph view.
//

- (void)sendPlotValueToGraphToDraw:(NSTimer*)theTimer
{
    
    CIVector *thisNumber = ((CIVector*)[theTimer userInfo]);
    float number = thisNumber.X;
    float maximar = thisNumber.Y;
    
    //    static float oldMax = 0;
    //
    //    if(maximar <= 0)
    //    {
    //        maximar = oldMax;
    //    }
    //    else
    //    {
    //        oldMax = maximar;
    //    }
    
    if( maximar > 200 )
    {
        maximar = 0;
    }
    
    [self.heartBeatGraphView addX:number y:maximar z:0];
}

@end

