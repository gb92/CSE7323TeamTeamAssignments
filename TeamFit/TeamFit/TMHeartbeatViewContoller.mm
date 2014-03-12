//
//  TMHeartbeatview.m
//  TeamFit
//
//  Created by ch484-mac6 on 3/12/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMHeartbeatViewController.h"
#import <opencv2/highgui/cap_ios.h>

using namespace cv;

@interface TMHeartbeatViewController () <CvVideoCameraDelegate>
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
        meanOfRedValues.clear();
    }
    

    char text[50];
    sprintf(text,"Avg. B: %.1f, G: %.1f,R: %.1f, H: %d", avgPixelIntensity.val[0],avgPixelIntensity.val[1],avgPixelIntensity.val[2], heartBeat );
    cv::putText(image, text, cv::Point(10, 20), FONT_HERSHEY_PLAIN, 1, Scalar::all(255), 1,2);
    
}

int countLocalMaximaFromArray( std::vector<float>& array )
{
    int result = 0;
    
    static const float ErrorRate = 0.1f;
    static const int windowSize = 3;
    std::vector<float> window;
    window.resize( windowSize );
    
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
            
            // Hack lol
            pCurrentPointer = pCurrentPointer + 2;
            previousMaxValue = currentMaxValue;
            
            continue;
            
        }

        // move window
        pCurrentPointer = pCurrentPointer + 1;
        
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
}


-(void)viewDidAppear:(BOOL)animated{
    
    
[super viewDidAppear:animated];
[self.videoCamera start];

}


-(void)viewWillDisappear:(BOOL)animated{
    
    [self.videoCamera stop];
    [super viewWillDisappear:animated];
    
}


@end
