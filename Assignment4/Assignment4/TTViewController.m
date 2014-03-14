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
    
    
    __block NSDictionary *opts = @{CIDetectorAccuracy: CIDetectorAccuracyLow, CIDetectorTracking:@YES};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:self.videoManager.ciContext options:opts];
    
    __weak typeof(self) weakSelf=self;
    
    [self.videoManager setProcessBlock:^(CIImage *cameraImage){
        if(weakSelf != nil)
        {
            A4GraphicsOverlay *overlay=(A4GraphicsOverlay *)weakSelf.view;
            //overlay.imageHeight=cameraImage.properties
            opts = @{CIDetectorImageOrientation: [VideoAnalgesic ciOrientationFromDeviceOrientation:[UIApplication sharedApplication].statusBarOrientation], CIDetectorEyeBlink:@YES, CIDetectorSmile:@YES};
            NSArray *faceFeatures = [detector featuresInImage: cameraImage options:opts];
        
            //NSLog(@"Num Faces %ld", [faceFeatures count]);
            if(faceFeatures.count >0)
            {
                NSMutableArray *faces=[[NSMutableArray alloc] initWithCapacity:faceFeatures.count];
                for(CIFaceFeature *face in faceFeatures){
                   //NSLog(@"ITS A FACE");
                    A4Face *newFace=[[A4Face alloc]init];
                    newFace.face=face.bounds;
                    //overlay.rectAroundFace = CGRectMake(face.bounds.origin.x, face.bounds.origin.y, face.bounds.size.width, face.bounds.size.height);
                    
                    
                    if(face.hasMouthPosition)
                    {
                        CGRect mouthRect= CGRectMake(face.mouthPosition.x-10, face.mouthPosition.y-10, 20, 20);
                        
                        newFace.mouth=mouthRect;
                        newFace.hasMouth=YES;
                        newFace.isSmiling=face.hasSmile;
                        NSLog(@"smiling:%@",face.hasSmile?@"YES": @"NO");
                        
                        //[faces insertObject:[NSValue valueWithCGRect:mouthRect] atIndex:faces.count];
                    }
                    if(face.hasLeftEyePosition)
                    {
                        CGRect leftEyeRect= CGRectMake(face.leftEyePosition.x-5, face.leftEyePosition.y-5, 10, 10);
                        newFace.leftEye=leftEyeRect;
                        newFace.hasLeftEye=YES;
                        newFace.isLeftEyeClosed=face.leftEyeClosed;
                        
                        NSLog(@"leftEyeClosed:%@",face.leftEyeClosed?@"YES": @"NO");
                        
                        //[faces insertObject:[NSValue valueWithCGRect:leftEyeRect] atIndex:faces.count];
                    }
                    if(face.hasRightEyePosition)
                    {
                        CGRect rightEyeRect= CGRectMake(face.rightEyePosition.x-5, face.rightEyePosition.y-5, 10, 10);
                        newFace.rightEye=rightEyeRect;
                        newFace.hasRightEye=YES;
                        newFace.isRightEyeClosed=face.rightEyeClosed;
                        NSLog(@"rightEyeClosed:%@",face.rightEyeClosed?@"YES": @"NO");
                        //[faces insertObject:[NSValue valueWithCGRect:rightEyeRect] atIndex:faces.count];
                    }
                    
                    [faces insertObject:newFace atIndex:faces.count];
                    
                }
                overlay.faceRects=faces;
                
            }
            else
            {
                overlay.faceRects=nil;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                CGAffineTransform transform=CGAffineTransformMakeRotation(M_PI_2);
//                CGAffineTransformConcat(transform, CGAffineTransformMakeScale(1.0, -1.0));
//                
//                overlay.transform=transform;
                [overlay setNeedsDisplay];
            });
        }
        return cameraImage;
    }];
//    [self.videoManager setProcessBlock:^(CIImage *cameraImage){
//        CGSize imageSize=([UIApplication sharedApplication].delegate).window.frame.size;
//        
//        //NSLog(@"Height: %f Width: %f", imageSize.height, imageSize.width);
//        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        
//        opts = @{CIDetectorImageOrientation: [VideoAnalgesic ciOrientationFromDeviceOrientation:[UIApplication sharedApplication].statusBarOrientation]};
//        NSArray *faceFeatures = [detector featuresInImage: cameraImage];
//        NSLog(@"Num Faces %ld", [faceFeatures count]);
//        
//        CGContextTranslateCTM(context, 0, imageSize.height);
//        CGContextScaleCTM(context, -1.0f, 1.0f);
//        
//        for(CIFaceFeature *face in faceFeatures){
//            
//            CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//            CGContextAddRect(context, face.bounds);
//            CGContextStrokePath(context);
//        }
//        UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
//        UIImageView *imageView=(UIImageView *)weakSelf.view;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            imageView.image=image;
//        });
//        
//        UIGraphicsEndImageContext();
//        return cameraImage;
//    }];
    
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
