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

static const int kFramesPerSec = 24;
static const int kSampleSecond = 5;

@interface TMHeartbeatViewController () <CvVideoCameraDelegate>
@property (weak, nonatomic) IBOutlet APLGraphView *heartBeatGraphView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCamera* videoCamera;
@property (strong, nonatomic) NSMutableArray *redAverageValues;

@end

@implementation TMHeartbeatViewController
#ifdef __cplusplus
    std::vector<float> meanOfRedValues;
static const int MEAN_OF_RED_VALUES_ARRAY_SIZE = kSampleSecond * kFramesPerSec;
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
        // Make sure that the color is red.
        // and push data to the buffer.
        //
        if( (avgPixelIntensity[0] < 50) && (avgPixelIntensity[1] < 30) && (avgPixelIntensity[2] < 252) )
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
    
    
    // Display color values and heartrate onto the image.
    char text[50];
    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f, H: %d", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2], heartBeat * 60 / kSampleSecond );
    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
}

void normalizeData( std::vector<float>& array, float scaleFactor )
{
    int minOfThisList = (int)minValueOfArray( array.begin(), array.end());
    int maxOfThisList = (int)maxValueOfArray( array.begin(), array.end())+1;
    
    for( int i=0; i<array.size(); i++ )
    {
        array[i] = (array[i] - minOfThisList) / (maxOfThisList-minOfThisList);
        array[i] *= scaleFactor;
    }
    
}

int countLocalMaximaFromArray( std::vector<float>& array )
{
    int result = 0;
    
    static const float ErrorRate = 0.000001f;
    static const int windowSize = 9;
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
    
    normalizeData( array, 1000 );
    
    while( pCurrentPointer < pEndWindow)
    {
        currentMaxValue = maxValueOfArray( pCurrentPointer, pCurrentPointer + windowSize );

        float thisError = (previousMaxValue - currentMaxValue);
        
        if( thisError < 0 ) thisError *= -1.0;
        
        if ( thisError < ErrorRate )
        {

            result++;
            
            *maxValueListIterator = *pCurrentPointer;
            
            // Hack lol
            pCurrentPointer = pCurrentPointer + windowSize;
            previousMaxValue = 0;
            
            // Debug mask
            //
            maxValueListIterator = maxValueListIterator + windowSize;
            
            //
            // End debug mask
            
            continue;
            
        }
        else
        {
            
            // move window
            pCurrentPointer = pCurrentPointer + 2;
            
            // Debug mask---
            maxValueListIterator = maxValueListIterator + 2;
            // end Debug mask---
            
            previousMaxValue = currentMaxValue;
        }

    }
    
    return result;
}

float maxValueOfArray( std::vector<float>::iterator beginOfWindow, std::vector<float>::iterator endOfWindow )
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

float minValueOfArray( std::vector<float>::iterator beginOfWindow, std::vector<float>::iterator endOfWindow )
{
    float min = 99999;
    
    std::vector<float>::iterator currentPoint = beginOfWindow;
    
    while( currentPoint < endOfWindow )
    {
        min = std::min( *currentPoint, min );
        currentPoint++;
    }
    
    return min;
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
        _videoCamera.defaultFPS = kFramesPerSec;
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
    static const float kTimePerSec = (1.0 / (float)kFramesPerSec);
    
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
