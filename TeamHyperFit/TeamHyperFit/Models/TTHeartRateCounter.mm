//
//  TTHeartRateCounter.m
//  TeamHyperFit
//
//  Created by ch484-mac7 on 4/30/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTHeartRateCounter.h"
#import <AVFoundation/AVFoundation.h>
#import <opencv2/highgui/cap_ios.h>
#import <numeric>

using namespace cv;

static const int kFramesPerSec = 24;
static const int kSampleSecond = 3;

@interface TTHeartRateCounter() <CvVideoCameraDelegate>

@property( strong, nonatomic) NSNumber* currentHeartRate;
@property (strong, nonatomic) CvVideoCamera* videoCamera;

@property( nonatomic ) BOOL isStarted;

@end

@implementation TTHeartRateCounter
{
#ifdef __cplusplus
std::vector<float> meanOfRedValues;
std::vector<float>maximumValueList;
#endif
    
    NSInteger timeCount;
}

static const int MEAN_OF_RED_VALUES_ARRAY_SIZE = kSampleSecond * kFramesPerSec;


-(CvVideoCamera *)videoCamera
{
    if(!_videoCamera)
    {
        _videoCamera= [[CvVideoCamera alloc ] initWithParentView:nil];
        _videoCamera.delegate = self;
        _videoCamera.defaultAVCaptureDevicePosition=AVCaptureDevicePositionBack;
        _videoCamera.defaultAVCaptureSessionPreset=AVCaptureSessionPreset352x288;
        _videoCamera.defaultAVCaptureVideoOrientation=AVCaptureVideoOrientationLandscapeLeft;
        _videoCamera.defaultFPS = kFramesPerSec;
        _videoCamera.grayscaleMode = NO;
        
    }
    return  _videoCamera;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.currentHeartRate = @(0);
    }
    
    return self;
}

-(void)start
{

    if (![self isStarted])
    {
    
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device unlockForConfiguration];
        }
        
        [self.videoCamera start];
        
        self.isStarted = YES;
    }
}

-(void)stop
{
    if ([self isStarted])
    {
	
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }
        
        [self.videoCamera stop];
        
        self.isStarted = NO;
    }
}

-(NSNumber*)getHeartRate
{
    return @(([self.currentHeartRate floatValue] ) * 60.0 / ( timeCount / kFramesPerSec ) );
}

-(BOOL)isStated
{
    return self.isStarted;
}

- (NSString *)heartRateZoneForGender:(TTGender)gender atAge:(NSUInteger)age
{
	int heartRate = [[self getHeartRate] intValue];
	//NSLog(@"Heart Rate: %i", heartRate);
	
	int maximumHeartRate;
	if (gender == TTGenderMale)
	{
		maximumHeartRate = 214 - (age * 0.8);
	}
	else
	{
		maximumHeartRate = 209 - (age * 0.7);
	}

	//NSLog(@"Maximum Heart Rate: %i", maximumHeartRate);
	if (heartRate >= maximumHeartRate*0.5 && heartRate < maximumHeartRate*0.6)
	{
		return @"VeryLight";
	}
	else if (heartRate >= maximumHeartRate*0.6 && heartRate < maximumHeartRate*0.7)
	{
		return @"Light";
	}
	else if (heartRate >= maximumHeartRate*0.7 && heartRate < maximumHeartRate*0.8)
	{
		return @"Moderate";
	}
	else if (heartRate >= maximumHeartRate*0.8 && heartRate < maximumHeartRate*0.9)
	{
		return @"Hard";
	}
	else if (heartRate >= maximumHeartRate*0.9 && heartRate < maximumHeartRate)
	{
		return @"Maximum";
	}
	else
		return @"Resting";
}

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
		
//        if ((avgPixelIntensity[0] < 50 && avgPixelIntensity[1] < 50 && avgPixelIntensity[2] > 200 && avgPixelIntensity[2] < 255) ||
//			(avgPixelIntensity[0] < 10 && avgPixelIntensity[1] < 10 && avgPixelIntensity[2] > 45 && avgPixelIntensity[2] < 113)) // Changed: Consider dark red as a sample
//		{
            meanOfRedValues.push_back( avgPixelIntensity.val[2] );
            timeCount++;
//		}
//        else
//        {
//			NSLog(@"Please place your finger at the back camera of the phone.");
//        }
    }
    else
    {
        [self normalizeData: meanOfRedValues scaleFactor:6 ];
        
        //NSLog(@"Hear Rate : %@\n", self.currentHeartRate);
        
        int newHeartRate = [self countLocalMaximaFromArray:meanOfRedValues] /* (-1) Error at the edge of data */;
        self.currentHeartRate = @([self.currentHeartRate intValue] + newHeartRate);
        
        NSLog(@"Hear Rate new : %d\n", newHeartRate);
        
        std::vector<float>drawingBuffer;
        drawingBuffer.assign(meanOfRedValues.begin(), meanOfRedValues.end());
        
        std::vector<float>drawingMaximarBuffer;
        drawingMaximarBuffer.assign(maximumValueList.begin(), maximumValueList.end());
        
        meanOfRedValues.clear();
    }
    
}

-(void) normalizeData:( std::vector<float>&) array scaleFactor: (float)scaleFactor
{
	
    int minOfThisList = (int)[self minValueOfArray: array.begin() endOfWindow: array.end()];
    int maxOfThisList = (int)[self maxValueOfArray: array.begin() endOfWindow: array.end()]+1;
    
    const float range = (float)(maxOfThisList-minOfThisList);
    const float rangeInverse = 1.0/range;
    
    for( int i=0; i<array.size(); i++ )
    {
        float substractedValue = (array[i] - minOfThisList);
        array[i] = substractedValue * rangeInverse;
        array[i] *= scaleFactor;
    }
    
}

-(int) countLocalMaximaFromArray:(const std::vector<float>)array
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
        currentMaxValue = [self maxValueOfArray: pCurrentPointer endOfWindow: pCurrentPointer + windowSize ];
		
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

-(float) maxValueOfArray:( std::vector<float>::const_iterator) beginOfWindow endOfWindow:(std::vector<float>::const_iterator) endOfWindow
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

-(float) minValueOfArray:( std::vector<float>::const_iterator) beginOfWindow endOfWindow:(std::vector<float>::const_iterator) endOfWindow
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

@end
