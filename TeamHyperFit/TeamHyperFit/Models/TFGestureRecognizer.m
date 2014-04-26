//
//  TFGestureRecognizer.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TFGestureRecognizer.h"


#import <CoreMotion/CoreMotion.h>


#import "TTMotionDataBuffer.h"
#import "TTWebServiceManager.h"
#import "TFGestureRecognizerDelegate.h"

@interface TFGestureRecognizer()

@property (strong, nonatomic) CMMotionManager *cmMotionManager;
@property (strong, nonatomic) TTMotionDataBuffer *ttMotionDataBuffer;
@property (strong, nonatomic) TTWebServiceManager *ttWebServiceManager;

@end

@implementation TFGestureRecognizer
{
    dispatch_queue_t motionCaptureQueue;
}


-(id) initWithModelDSID:(NSNumber *)modelDSID
{
    if(self == nil)
    {
        self=[super init];
        self.modelDataSetID=modelDSID;
    }
    return self;
}

-(NSNumber *) modelDataSetID
{
    if(_modelDataSetID == nil)
    {
        _modelDataSetID=@(0);
    }
    return _modelDataSetID;
}

-(TTMotionDataBuffer *) ttMotionDataBuffer
{
    if(_ttMotionDataBuffer == nil)
    {
        _ttMotionDataBuffer= [[TTMotionDataBuffer alloc] initWithBufferLength:50];
    }
    return _ttMotionDataBuffer;
}

-(CMMotionManager *) cmMotionManager
{
    if(_cmMotionManager == nil)
    {
        _cmMotionManager = [[CMMotionManager alloc] init];
        
        if(![_cmMotionManager isDeviceMotionAvailable]){
            _cmMotionManager = nil;
        }

    }
    return _cmMotionManager;
}

-(TTWebServiceManager *) ttWebServiceManager
{
    if(_ttWebServiceManager == nil)
    {
        NSDictionary *appDictionary=[[NSBundle mainBundle] infoDictionary];
        NSString *serverURL=[appDictionary valueForKey:@"TeamFitServerURL"];
        NSNumber *serverPort=[appDictionary valueForKey:@"TeamFitServerPort"];
        
        _ttWebServiceManager=[[TTWebServiceManager alloc]initWithURL:serverURL port:serverPort];
    }
    
    return _ttWebServiceManager;
}


-(void) startGestureCapture
{
    if(motionCaptureQueue == nil)
        motionCaptureQueue=dispatch_queue_create("edu.smu.TeamTeam.MotionCapture", NULL);
    
    if(self.cmMotionManager)
    {
        if (![self.cmMotionManager isDeviceMotionActive]) {
            [self.cmMotionManager startDeviceMotionUpdates];
        }
        
        NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
        myQueue.maxConcurrentOperationCount = 1;
        
        [self.cmMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmMotionManager
         startDeviceMotionUpdatesToQueue:myQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {
             
             [self.ttMotionDataBuffer addNewAccelerationData:motion.userAcceleration.x
                                   withY:motion.userAcceleration.y
                                   withZ:motion.userAcceleration.z];
             
         }];
    }
}

-(void) stopGestureCapture
{
    [self.cmMotionManager stopDeviceMotionUpdates];
}


-(void) accelerationDataBufferFilled:(NSArray *)accelerationVector
{
    NSLog(@"Acceleration Data Buffer Filled!");
    
    NSDictionary *appDictionary=[[NSBundle mainBundle] infoDictionary];
    NSString *predictRequest=[appDictionary valueForKey:@"TeamFitPredictRequest"];
    
    NSDictionary *dataToSendToServer=@{@"data":accelerationVector,
                                       @"dsid":self.modelDataSetID};
                                              
    
    [self.ttWebServiceManager sendPost:dataToSendToServer to:predictRequest callback:^(NSData *data) {
       
        NSError *error=[[NSError alloc] init];
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        
        // we should get back the feature data from the server and the label it parsed
        NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"feature"]];
        NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"label"]];
        NSLog(@"received %@ and %@",featuresResponse,labelResponse);
       
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gestureRecognized:)])
        {
            TFGesture *gesture=[[TFGesture alloc] init];
            // TODO: add data to the gesture object
            
            [self.delegate gestureRecognized:gesture];
        }
    }];
    
}

@end
