//
//  TTViewController.m
//  TeamVision
//
//  Created by ch484-mac6 on 3/11/14.
//  Copyright (c) 2014 Team team. All rights reserved.
//

#import "TTViewController.h"
#import "VideoAnalgesic.h"
#import "A4GraphicsOverlay.h"
#import "A4Face.h"

@interface TTViewController ()
@property (strong,nonatomic) VideoAnalgesic *videoManager;

@property int currentCamera;
@end

@implementation TTViewController


-(VideoAnalgesic *) videoManager
{ if(!_videoManager){

    _videoManager= [VideoAnalgesic captureManager];
    _videoManager.preset = AVCaptureSessionPresetMedium;
    [_videoManager setCameraPosition:AVCaptureDevicePositionFront];
    self.currentCamera=0;

}

return _videoManager;
}




- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    __block NSDictionary *opts = @{CIDetectorAccuracy:CIDetectorAccuracyHigh, CIDetectorTracking:@YES};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:self.videoManager.ciContext options:opts];
    
    __block CIFilter *gradientFilter=[CIFilter filterWithName:@"CIGaussianGradient"];
    __block CIFilter *overlayFilter=[CIFilter filterWithName:@"CISourceOverCompositing"];
    __block CIColor *faceColor=[CIColor colorWithRed:255 green:0 blue:0 alpha:1];
    __block CIColor *endColor=[CIColor colorWithRed:255 green:0 blue:0 alpha:0];
    __block CIColor *eyeOpenColor=[CIColor colorWithRed:255 green:215 blue:0 alpha:1];
    __block CIColor *eyeClosedColor=[CIColor colorWithRed:0 green:0 blue:0 alpha:1];
    __block CIColor *mouthColor=[CIColor colorWithRed:0 green:255 blue:0 alpha:1];
    __block CIColor *mouthSmileColor=[CIColor colorWithRed:0 green:0 blue:255 alpha:1];
    
    __weak typeof(self) weakSelf=self;
    
    [self.videoManager setProcessBlock:^(CIImage *cameraImage){
        
        if(weakSelf != nil)
        {
            opts = @{CIDetectorImageOrientation: [VideoAnalgesic ciOrientationFromDeviceOrientation:[UIApplication sharedApplication].statusBarOrientation], CIDetectorEyeBlink:@YES, CIDetectorSmile:@YES};
            NSArray *faceFeatures = [detector featuresInImage: cameraImage options:opts];
            NSLog(@"Num Faces %ld", faceFeatures.count);
            //CIImage *overlayImage;
            for(CIFaceFeature *face in faceFeatures)
            {
                
                //draw over face
                [gradientFilter setDefaults];
                [overlayFilter setDefaults];
                
               
                CIVector *centerVector=[CIVector vectorWithX:face.bounds.origin.x+face.bounds.size.width/2
                                                          Y:face.bounds.origin.y+face.bounds.size.height/2];
                float radius=face.bounds.size.height;
                NSNumber *rad=[NSNumber numberWithFloat:radius];
                
                
                [gradientFilter setValue:centerVector forKey:@"inputCenter"];
                [gradientFilter setValue:rad forKey:@"inputRadius"];
                [gradientFilter setValue:faceColor forKey:@"inputColor0"];
                [gradientFilter setValue:endColor forKey:@"inputColor1"];
            
                CIImage *outputImage=[gradientFilter outputImage];
                
                
                [overlayFilter setValue:outputImage forKey:kCIInputImageKey];
                [overlayFilter setValue:cameraImage forKey:kCIInputBackgroundImageKey];
                
                cameraImage=overlayFilter.outputImage;
                
                //draw over left eye
                if(face.hasLeftEyePosition)
                {
                
                    CIVector *centerVector=[CIVector
                                            vectorWithX:face.leftEyePosition.x
                                                      Y:face.leftEyePosition.y];
                    
                    float radius=face.bounds.size.width/4;
                    NSNumber *rad=[NSNumber numberWithFloat:radius];
                    
                    
                    [gradientFilter setValue:centerVector forKey:@"inputCenter"];
                    [gradientFilter setValue:rad forKey:@"inputRadius"];
                    if(face.leftEyeClosed)
                    {
                        [gradientFilter setValue:eyeClosedColor forKey:@"inputColor0"];
                    }
                    else
                    {
                        [gradientFilter setValue:eyeOpenColor forKey:@"inputColor0"];
                    }
                    [gradientFilter setValue:endColor forKey:@"inputColor1"];
                    CIImage *outputImage=[gradientFilter outputImage];
                    
                    
                    [overlayFilter setValue:outputImage forKey:kCIInputImageKey];
                    [overlayFilter setValue:cameraImage forKey:kCIInputBackgroundImageKey];
                    
                    cameraImage=overlayFilter.outputImage;
                }

                //draw over right eye
                if(face.hasRightEyePosition)
                {
                    
                    CIVector *centerVector=[CIVector
                                            vectorWithX:face.rightEyePosition.x
                                            Y:face.rightEyePosition.y];
                    
                    float radius=face.bounds.size.width/4;
                    NSNumber *rad=[NSNumber numberWithFloat:radius];
                    
                    
                    [gradientFilter setValue:centerVector forKey:@"inputCenter"];
                    [gradientFilter setValue:rad forKey:@"inputRadius"];
                    if(face.rightEyeClosed)
                    {
                        [gradientFilter setValue:eyeClosedColor forKey:@"inputColor0"];
                    }
                    else
                    {
                        [gradientFilter setValue:eyeOpenColor forKey:@"inputColor0"];
                    }
                    [gradientFilter setValue:endColor forKey:@"inputColor1"];
                    CIImage *outputImage=[gradientFilter outputImage];
                    
                    
                    [overlayFilter setValue:outputImage forKey:kCIInputImageKey];
                    [overlayFilter setValue:cameraImage forKey:kCIInputBackgroundImageKey];
                    
                    cameraImage=overlayFilter.outputImage;
                }
                
                //draw over left eye
                if(face.hasMouthPosition)
                {
                    
                    CIVector *centerVector=[CIVector
                                            vectorWithX:face.mouthPosition.x
                                            Y:face.mouthPosition.y];
                    
                    float radius=face.bounds.size.width/2;
                    NSNumber *rad=[NSNumber numberWithFloat:radius];
                    
                    
                    [gradientFilter setValue:centerVector forKey:@"inputCenter"];
                    [gradientFilter setValue:rad forKey:@"inputRadius"];
                    if(face.hasSmile)
                    {
                        [gradientFilter setValue:mouthSmileColor forKey:@"inputColor0"];
                    }
                    else
                    {
                        [gradientFilter setValue:mouthColor forKey:@"inputColor0"];
                    }
                    [gradientFilter setValue:endColor forKey:@"inputColor1"];
                    CIImage *outputImage=[gradientFilter outputImage];
                    
                    
                    [overlayFilter setValue:outputImage forKey:kCIInputImageKey];
                    [overlayFilter setValue:cameraImage forKey:kCIInputBackgroundImageKey];
                    
                    cameraImage=overlayFilter.outputImage;
                }

                
            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [overlay setNeedsDisplay];
//            });
        }
        return cameraImage;
    }];
    [self changeColorMatching];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(![self.videoManager isRunning])
        [self.videoManager start];
    
}

- (IBAction)switchCameraButtonPressed:(id)sender {
    
    if([self.videoManager isRunning])
    {
        if(self.currentCamera==0)
        {
            [self.videoManager stop];
            [self.videoManager setCameraPosition:AVCaptureDevicePositionBack];
            self.currentCamera=1;
            [self.videoManager start];
        }
        else
        {
            [self.videoManager stop];
            [self.videoManager setCameraPosition:AVCaptureDevicePositionFront];
            self.currentCamera=0;
            [self.videoManager start];
        }
    }
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    if([self.videoManager isRunning])
        [self.videoManager stop];
    [super viewDidDisappear:animated];
}

-(void)changeColorMatching{
    [self.videoManager shouldColorMatch:YES];
}

@end
