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

#define LogCall() NSLog(@"%d %s", __LINE__, __func__) // Changed:

using namespace cv;

static const int kFramesPerSec = 24;
static const int kSampleSecond = 5;

@interface TMHeartbeatViewController () <CvVideoCameraDelegate>
@property (weak, nonatomic) IBOutlet APLGraphView *heartBeatGraphView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) CvVideoCamera* videoCamera;

@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

@property (nonatomic) float heartRate;
@end

@implementation TMHeartbeatViewController
#ifdef __cplusplus
std::vector<float> meanOfRedValues;
static const int MEAN_OF_RED_VALUES_ARRAY_SIZE = kSampleSecond * kFramesPerSec;
#endif


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

std::vector<float>maximumValueList;

#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    Mat image_copy;
    //============================================
    // get average pixel intensity
    cvtColor(image, image_copy, CV_BGRA2BGR); // get rid of alpha for processing
    Scalar avgPixelIntensity = cv::mean( image_copy );
    
    if( meanOfRedValues.size() < MEAN_OF_RED_VALUES_ARRAY_SIZE )
    {
        // Make sure that the color is red.
        // and push data to the buffer.
        //

        if ((avgPixelIntensity[0] < 50 && avgPixelIntensity[1] < 50 && avgPixelIntensity[2] > 200 && avgPixelIntensity[2] < 255) ||
			(avgPixelIntensity[0] < 10 && avgPixelIntensity[1] < 10 && avgPixelIntensity[2] > 45 && avgPixelIntensity[2] < 113)) // Changed: Consider dark red as a sample
		{
            meanOfRedValues.push_back( avgPixelIntensity.val[2] );
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                [self.instructionLabel setText:@"Counting Heart Signal..."];
            });
		}
        else
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [self.instructionLabel setText:@"Please place your finger at the back camera of the phone."];
            });
        }
    }
    else
    {
        normalizeData( meanOfRedValues, 6 );
        
        NSLog(@"Hear Rate : %f\n", self.heartRate);
        
        float newHeartRate = countLocalMaximaFromArray(meanOfRedValues) - 1 /* (-1) Error at the edge of data */;
        self.heartRate = ( newHeartRate + self.heartRate ) / 2.0;
        
        NSLog(@"Hear Rate new : %f\n", newHeartRate);
        
        std::vector<float>drawingBuffer;
        drawingBuffer.assign(meanOfRedValues.begin(), meanOfRedValues.end());
        
        std::vector<float>drawingMaximarBuffer;
        drawingMaximarBuffer.assign(maximumValueList.begin(), maximumValueList.end());
		
		
        dispatch_async(dispatch_get_main_queue(),^{
            [self.heartRateLabel setText:[NSString stringWithFormat:@"%.0f",self.heartRate * 60 / kSampleSecond]];
            
            [self drawGraph:drawingBuffer withMaximarList:drawingMaximarBuffer];
        });
        
        meanOfRedValues.clear();
    }
    
    
    // Display color values and heartrate onto the image.
//    char text[50];
//    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f, H: %.0f", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2], self.heartRate * 60 / kSampleSecond );
//    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
}

void normalizeData( std::vector<float>& array, float scaleFactor )
{
	
    int minOfThisList = (int)minValueOfArray( array.begin(), array.end());
    int maxOfThisList = (int)maxValueOfArray( array.begin(), array.end())+1;
    const float range = (float)(maxOfThisList-minOfThisList);
    const float rangeInverse = 1.0/range;
    
    for( int i=0; i<array.size(); i++ )
    {
        float substractedValue = (array[i] - minOfThisList);
        array[i] = substractedValue * rangeInverse;
        array[i] *= scaleFactor;
    }
    
}

int countLocalMaximaFromArray(const std::vector<float> array)
{
    int result = 0;
    
    static const double ErrorRate = 0.000001;
    static const int windowSize = 11;
    std::vector<float> window;
    window.resize( windowSize );
    
    //Debug
    maximumValueList.clear();
    maximumValueList.resize( array.size() );
    
    std::vector<float>::iterator maxValueListIterator = maximumValueList.begin();
    
    //End Debug
    
	float previousMaxValue = 0.0f;
    float currentMaxValue = 0.0f;
    
    std::vector<float>::const_iterator pBeginOfBuffer = array.begin();
    std::vector<float>::const_iterator pEndOfBuffer = array.end();
    std::vector<float>::const_iterator pCurrentPointer = pBeginOfBuffer;
    
    
    while( pCurrentPointer < pEndOfBuffer)
    {
        currentMaxValue = maxValueOfArray( pCurrentPointer, pCurrentPointer + windowSize );
		
        double thisError = (previousMaxValue - currentMaxValue); // Changed:
        
        if( thisError < 0 ) thisError *= -1.0;
        
        if ( thisError < ErrorRate ) // Found local maximar
        {
            
            //! Debug mask
            //
            {
                *maxValueListIterator = currentMaxValue;
                maxValueListIterator = maxValueListIterator + windowSize;
            }
            //
            // End debug mask
            
            
            result++;
            
            // Hack lol
            pCurrentPointer = pCurrentPointer + windowSize;
            previousMaxValue = 0;
            
			
        }
        else // Not Found local maximra
        {
            
            // move window
            pCurrentPointer = pCurrentPointer + 2;
            
            // Debug mask---
            //*maxValueListIterator = currentMaxValue;
            maxValueListIterator = maxValueListIterator + 2;
            
            // end Debug mask---
            
            previousMaxValue = currentMaxValue;
            
            
        }
		
    }
    
    return result;
}

float maxValueOfArray( std::vector<float>::const_iterator beginOfWindow, std::vector<float>::const_iterator endOfWindow )
{
	
    float max = -MAXFLOAT;
    
    std::vector<float>::const_iterator currentPoint = beginOfWindow;
    
    while( currentPoint < endOfWindow )
    {
        max = std::max( *currentPoint, max );
        currentPoint++;
    }
    
    return max;
}

float minValueOfArray( std::vector<float>::const_iterator beginOfWindow, std::vector<float>::const_iterator endOfWindow )
{
	
    float min = MAXFLOAT;
    
    std::vector<float>::const_iterator currentPoint = beginOfWindow;
    
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
    
    
#ifdef __cplusplus
    meanOfRedValues.reserve( MEAN_OF_RED_VALUES_ARRAY_SIZE );
#endif
    
    
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

-(void)viewWillAppear:(BOOL)animated
{
    
	[super viewDidAppear:animated];
	[self.videoCamera start];
    
    [self setTorchOn:YES];
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    
    [self.videoCamera stop];
    [super viewWillDisappear:animated];
    
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.videoCamera layoutPreviewLayer];
}


@end

