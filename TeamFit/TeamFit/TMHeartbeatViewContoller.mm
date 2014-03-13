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

using namespace cv;

@interface TMHeartbeatViewController () <CvVideoCameraDelegate>
@property (weak, nonatomic) IBOutlet APLGraphView *heartBeatGraphView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCamera* videoCamera;
@property (strong, nonatomic) NSMutableArray *redAverageValues;

@end

@implementation TMHeartbeatViewController
#ifdef __cplusplus
    std::vector<float> meanOfRedValues;
static const int MEAN_OF_RED_VALUES_ARRAY_SIZE = 240;
#endif

-(NSMutableArray *)redAverageValues{
    if(!_redAverageValues)
    {_redAverageValues= [[NSMutableArray alloc] init];
        
    } return _redAverageValues;
}


- (IBAction)ToggleTorch:(UISwitch *)sender {
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
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:onoff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

std::vector<float>maximumValueList;

#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
     Mat image_copy;
    //============================================
    // get average pixel intensity
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    Scalar avgPixelIntensity = cv::mean( image_copy );

    
    static int heartBeat = 0;
    
    if( meanOfRedValues.size() < MEAN_OF_RED_VALUES_ARRAY_SIZE )
    {
        meanOfRedValues.push_back( avgPixelIntensity.val[2] );
    }
    else
    {
        heartBeat = countLocalMaximaFromArray( meanOfRedValues );
        
        std::vector<float>drawingBuffer;
        drawingBuffer.assign(meanOfRedValues.begin(), meanOfRedValues.end());
        
        std::vector<float>drawingMaximarBuffer;
        drawingMaximarBuffer.assign(maximumValueList.begin(), maximumValueList.end());
        
        
        dispatch_async(dispatch_get_main_queue(),^{
            [self drawGraph:drawingBuffer withMaximarList:drawingMaximarBuffer];
        });
        
        meanOfRedValues.clear();
    }
    
    
//    dispatch_async(dispatch_get_main_queue(),^{
//        
//            float plotedRed = (avgPixelIntensity.val[2] - (int)(avgPixelIntensity.val[2] - 0.5)) * 100;
//            [self.heartBeatGraphView addX:plotedRed y:0 z:0];
//        
//    });
    
    char text[50];
    
    
    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f, H: %d", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2], heartBeat * 6 );
    
    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
}



int countLocalMaximaFromArray( std::vector<float>& array )
{
    int result = 0;
    
    static const float ErrorRate = 0.000001f;
    static const int windowSize = 17;
    std::vector<float> window;
    window.resize( windowSize );
    
    //Debug
    maximumValueList.clear();
    maximumValueList.resize( array.size() );
    
    std::vector<float>::iterator maxValueListIterator = maximumValueList.begin();
    
    //End Debug
    
    
    float previousMaxValue = 0.0f;
    float currentMaxValue = 0.0f;
    
    std::vector<float>::iterator pBeginWindow = array.begin();
    std::vector<float>::iterator pEndWindow = array.end();
    std::vector<float>::iterator pCurrentPointer = pBeginWindow;
    
    while( pCurrentPointer < pEndWindow)
    {
        currentMaxValue = maxValueOfArray( array, pCurrentPointer, pCurrentPointer + windowSize );

        if ( abs(previousMaxValue - currentMaxValue) < ErrorRate )
        {
            result++;
            
            *maxValueListIterator = *pCurrentPointer;
            
            // Hack lol
            pCurrentPointer = pCurrentPointer + windowSize - 5;
            previousMaxValue = currentMaxValue;
            
            // Debug mask
            //
            maxValueListIterator = maxValueListIterator + windowSize -5;
            
            //
            // End debug mask
            
            continue;
            
        }

        // move window
        pCurrentPointer = pCurrentPointer + 10;
        
        // Debug mask---
        maxValueListIterator = maxValueListIterator + 10;
        // end Debug mask---
        
        previousMaxValue = currentMaxValue;
    }
    
    return result;
}

float maxValueOfArray( std::vector<float>& array, std::vector<float>::iterator beginOfWindow, std::vector<float>::iterator endOfWindow )
{
    float max = -99999;
    
    std::vector<float>::iterator currentPoint = beginOfWindow;
    
    while( currentPoint < endOfWindow )
    {
        max = std::max( *currentPoint, max );
        currentPoint++;
    }
    
    return max;
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



-(CvVideoCamera *)videoCamera{
    if(!_videoCamera)
    {
        _videoCamera= [[CvVideoCamera alloc ] initWithParentView:self.imageView];
        _videoCamera.delegate = self;
        _videoCamera.defaultAVCaptureDevicePosition=AVCaptureDevicePositionBack;
        _videoCamera.defaultAVCaptureSessionPreset=AVCaptureSessionPreset352x288;
        _videoCamera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationLandscapeLeft;
        _videoCamera.defaultFPS = 24;
        _videoCamera.grayscaleMode = NO;
        
        
    }
    return  _videoCamera;
}

#pragma mark - Overload functions

- (void)viewDidLoad
{
    [super viewDidLoad];
    

#ifdef __cplusplus
    meanOfRedValues.reserve( MEAN_OF_RED_VALUES_ARRAY_SIZE );
#endif

    
//    std::vector<float>arrayTest;
//    arrayTest.push_back(10.0f);
//    arrayTest.push_back(12.0f);
//    arrayTest.push_back(14.0f);
//    arrayTest.push_back(18.0f);
//    arrayTest.push_back(17.0f);
//    arrayTest.push_back(10.0f);
//    float a = maxValueOfArray(arrayTest, arrayTest.begin(), arrayTest.begin() + 3 );
//
//    NSLog(@"Max of this array %f", a );
    
    
//  std::vector<float>arrayTest;
//  arrayTest.push_back(10.0f);
//  arrayTest.push_back(12.0f);
//  arrayTest.push_back(13.0f);
//  arrayTest.push_back(14.0f);
//  arrayTest.push_back(15.0f);
//  arrayTest.push_back(16.0f);  //--1
//    arrayTest.push_back(15.0f);
//    arrayTest.push_back(14.0f);
//    arrayTest.push_back(13.0f);
//    arrayTest.push_back(12.0f);
//    arrayTest.push_back(11.0f);
//    arrayTest.push_back(12.0f);
//    arrayTest.push_back(13.0f);
//    arrayTest.push_back(14.0f);
//    arrayTest.push_back(15.0f);
//    arrayTest.push_back(16.0f); //--2
//    arrayTest.push_back(15.0f);
//    arrayTest.push_back(14.0f);
//    arrayTest.push_back(13.0f);
//    arrayTest.push_back(12.0f);
//    arrayTest.push_back(10.0f);
//    arrayTest.push_back(11.0f);
//    arrayTest.push_back(12.0f);
//    arrayTest.push_back(13.0f);
//    arrayTest.push_back(14.0f);
//    arrayTest.push_back(15.0f);
//    arrayTest.push_back(16.0f); //--3
//    arrayTest.push_back(15.0f);
//    arrayTest.push_back(14.0f);
//    arrayTest.push_back(13.0f);
//    arrayTest.push_back(12.0f);
//    arrayTest.push_back(10.0f);
//    
//    int numberOfLocalMaxima = countLocalMaximaFromArray(arrayTest);
//  
//    NSLog(@"Max of this array %d", numberOfLocalMaxima );
    
    
//      std::vector<float>arrayTest;
//      arrayTest.push_back(10.0f);
//      arrayTest.push_back(12.0f);
//      arrayTest.push_back(13.0f);
//      arrayTest.push_back(14.0f);
//      arrayTest.push_back(15.0f);
//      arrayTest.push_back(16.0f);  //--1
//        arrayTest.push_back(15.0f);
//        arrayTest.push_back(14.0f);
//        arrayTest.push_back(13.0f);
//        arrayTest.push_back(12.0f);
//        arrayTest.push_back(11.0f);
//        arrayTest.push_back(12.0f);
//        arrayTest.push_back(13.0f);
//        arrayTest.push_back(14.0f);
//        arrayTest.push_back(15.0f);
//        arrayTest.push_back(16.0f); //--2
//        arrayTest.push_back(15.0f);
//        arrayTest.push_back(14.0f);
//        arrayTest.push_back(13.0f);
//        arrayTest.push_back(12.0f);
//        arrayTest.push_back(10.0f);
//        arrayTest.push_back(11.0f);
//        arrayTest.push_back(12.0f);
//        arrayTest.push_back(13.0f);
//        arrayTest.push_back(14.0f);
//        arrayTest.push_back(15.0f);
//        arrayTest.push_back(16.0f); //--3
//        arrayTest.push_back(15.0f);
//        arrayTest.push_back(14.0f);
//        arrayTest.push_back(13.0f);
//        arrayTest.push_back(12.0f);
//        arrayTest.push_back(10.0f);
//    
//    [self drawGraph:arrayTest];
    
}

-(void) drawGraph:( std::vector<float> ) data withMaximarList:(std::vector<float>) maxList
{
    static const float kTimePerSec = (1.0 / 24.0);
    
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
    
    NSLog (@"Got the float: %f  : %f", number, maximar);
    
    number = (number - (235));
    number = (number < 0)? 0: number;
    number *= 100;
    
    maximar = (maximar - (235));
    maximar = (maximar < 0)? 0: maximar;
    maximar *= 100;
    
   [self.heartBeatGraphView addX:number y:maximar z:0];
}

-(void)viewDidAppear:(BOOL)animated{
    
    
[super viewDidAppear:animated];
[self.videoCamera start];
    
    [self setTorchOn:YES];

}


-(void)viewWillDisappear:(BOOL)animated{
    
    [self.videoCamera stop];
    [super viewWillDisappear:animated];
    
}


@end
