//
//  TFGestureRecognizer.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TFGestureRecognizer.h"
#import "TTAppDelegate.h"
#import "RingBuffer.h"


#import <CoreMotion/CoreMotion.h>


//#import "TTMotionDataBuffer.h"
#import "TTWebServiceManager.h"
//#import "TFGestureRecognizerDelegate.h"

#define kBufferLength 1024
#define numberOfFeatures 10 //MUST BE A MULTIPLE OF 3

@interface TFGestureRecognizer()

@property (strong, nonatomic) CMMotionManager *cmMotionManager;
//@property (strong, nonatomic) TTMotionDataBuffer *ttMotionDataBuffer;
@property (strong, nonatomic) TTWebServiceManager *ttWebServiceManager;

@property (strong,nonatomic) CMMotionManager *cmDeviceMotionManager;
@property (strong,nonatomic) NSMutableArray *gestureBuffer;

@property (strong, nonatomic) NSTimer *updateTimer;

@property BOOL performUpdates;

@property (strong, nonatomic) NSOperationQueue *motionCaptureQueue;
//@property (strong, nonatomic) NSOperationQueue *updatesQueue;
@end

@implementation TFGestureRecognizer
{
    dispatch_queue_t updatesQueue;
    int gestureTypeCount[4];
}
RingBuffer *ringBufferX;
RingBuffer *ringBufferY;
RingBuffer *ringBufferZ;
RingBuffer *ringBufferVector;

float *motionDataX;
float *motionDataY;
float *motionDataZ;
float *motionVector;
BOOL CurrentlyGesturing;

float *sampledGesture;
int windowSize = 60;
float threshold = .18;

//-(NSArray*) gestureTypeCount
//{
//    if (!_gestureTypeCount) {
//        _gestureTypeCount = @[@(0),@(0),@(0),@(0)];
//    }
//    
//    return _gestureTypeCount;
//}

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

-(NSMutableArray *) gestureBuffer
{
    if(_gestureBuffer == nil)
    {
        _gestureBuffer=[[NSMutableArray alloc] init];
    }
    return _gestureBuffer;
}

-(TTWebServiceManager *) ttWebServiceManager
{
    if(_ttWebServiceManager == nil)
    {
        
        _ttWebServiceManager=[[TTWebServiceManager alloc] init];
        _ttWebServiceManager.serverURL=@"http://teamhyperfit.cloudapp.net";
        _ttWebServiceManager.serverPort=@(8000);
    }
    
    return _ttWebServiceManager;
}

//-(NSOperationQueue *) updatesQueue
//{
//    if(_updatesQueue == nil)
//    {
//        _updatesQueue=[[NSOperationQueue alloc] init];
//        _updatesQueue.maxConcurrentOperationCount=1;
//    }
//    return _updatesQueue;
//}

-(NSOperationQueue *) motionCaptureQueue
{
    if(_motionCaptureQueue == nil)
    {
        _motionCaptureQueue=[[NSOperationQueue alloc] init];
        _motionCaptureQueue.maxConcurrentOperationCount=1;
    }
    return _motionCaptureQueue;
}

-(void) dealloc
{
    free(motionDataX);
    free(motionDataY);
    free(motionDataZ);
    free(motionVector);
    
    delete sampledGesture;
}

-(void)clearGesturePredictedData
{
    for(int i=0; i<4; i++)
    {
        gestureTypeCount[i] = 0;
    }
}

-(NSString*)printGestureResult
{
    NSString *result;
    for(int i=0; i<4; i++)
    {
        NSString *gestureName;
        
        if( i == 0 )
        {
            gestureName = @"jumping jack";
        }
        else if( i == 1 )
        {
            gestureName = @"push up";
        }
        else if( i == 2 )
        {
            gestureName = @"sit up";
        }
        else
        {
            gestureName = @"Squat?";
        }
        
        result = [NSString stringWithFormat:@"%@ \n %@ : %d", result, gestureName, gestureTypeCount[i] ];
    }
    
    self.log = result;
    NSLog(@"%@",result);
    return result;
}

-(void) startGestureCapture
{
    
    NSLog(@"Start Gesture Capture.");
    if(updatesQueue == nil)
        updatesQueue=dispatch_queue_create("edu.smu.TeamTeam", DISPATCH_QUEUE_CONCURRENT);
    
    if(ringBufferX == nil)
    {
        
        ringBufferX = new RingBuffer(kBufferLength,2);
        ringBufferY = new RingBuffer(kBufferLength,2);
        ringBufferZ = new RingBuffer(kBufferLength,2);
        ringBufferVector = new RingBuffer(kBufferLength,2);
        
        motionDataX = (float*)calloc(kBufferLength,sizeof(float));
        motionDataY = (float*)calloc(kBufferLength,sizeof(float));
        motionDataZ = (float*)calloc(kBufferLength,sizeof(float));
        motionVector = (float*)calloc(kBufferLength,sizeof(float));
        
        //create the sampled gesture buffer
        sampledGesture = new float[numberOfFeatures*3];

    }
    
    if(self.cmMotionManager)
    {
        if (![self.cmMotionManager isDeviceMotionActive]) {
            [self.cmMotionManager startDeviceMotionUpdates];
        }
        
        [self.cmMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmMotionManager
         startDeviceMotionUpdatesToQueue:self.motionCaptureQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {
             
             float dX = motion.userAcceleration.x;
             float dY = motion.userAcceleration.y;
             float dZ = motion.userAcceleration.z;
             float dV = sqrt(pow(dX,2)+pow(dY,2)+pow(dZ,2));
             
             ringBufferX->AddNewFloatData(&dX, 1);
             ringBufferY->AddNewFloatData(&dY, 1);
             ringBufferZ->AddNewFloatData(&dZ, 1);
             ringBufferVector->AddNewFloatData(&dV, 1);
             
         }];
        
        /*
         self.updateTimer=[NSTimer scheduledTimerWithTimeInterval:1.0/50.0
                                                          target:self
                                                        selector:@selector(update:)
                                                        userInfo:nil
                                                         repeats:YES];
         */
        dispatch_async(updatesQueue, ^{
            [self update];
        });
        self.performUpdates=YES;
    }
}


-(void) startTrainingGestureCapture
{
    if(updatesQueue == nil)
        updatesQueue=dispatch_queue_create("edu.smu.TeamTeam", DISPATCH_QUEUE_CONCURRENT);
    
    if(self.cmMotionManager)
    {
        if (![self.cmMotionManager isDeviceMotionActive]) {
            [self.cmMotionManager startDeviceMotionUpdates];
        }
        
        if(ringBufferX == nil)
        {
            
            ringBufferX = new RingBuffer(kBufferLength,2);
            ringBufferY = new RingBuffer(kBufferLength,2);
            ringBufferZ = new RingBuffer(kBufferLength,2);
            ringBufferVector = new RingBuffer(kBufferLength,2);
            
            motionDataX = (float*)calloc(kBufferLength,sizeof(float));
            motionDataY = (float*)calloc(kBufferLength,sizeof(float));
            motionDataZ = (float*)calloc(kBufferLength,sizeof(float));
            motionVector = (float*)calloc(kBufferLength,sizeof(float));
            
            //create the sampled gesture buffer
            sampledGesture = new float[numberOfFeatures*3];
            
        }

        
        [self.cmMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmMotionManager
         startDeviceMotionUpdatesToQueue:self.motionCaptureQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {
             
             float dX = motion.userAcceleration.x;
             float dY = motion.userAcceleration.y;
             float dZ = motion.userAcceleration.z;
             float dV = sqrt(pow(dX,2)+pow(dY,2)+pow(dZ,2));
             
             ringBufferX->AddNewFloatData(&dX, 1);
             ringBufferY->AddNewFloatData(&dY, 1);
             ringBufferZ->AddNewFloatData(&dZ, 1);
             ringBufferVector->AddNewFloatData(&dV, 1);
             
         }];
        
        /*
         self.updateTimer=[NSTimer scheduledTimerWithTimeInterval:1.0/50.0
         target:self
         selector:@selector(update:)
         userInfo:nil
         repeats:YES];
         */
        self.performUpdates=YES;
        dispatch_async(updatesQueue, ^{
            [self updateTraining];
        });
        
    }
}

-(void) stopGestureCapture
{
    NSLog(@"Stop Update Traning");
    [self.cmMotionManager stopDeviceMotionUpdates];
    self.performUpdates=NO;
}

-(void) uploadDownSampledGesture
{
    NSLog(@"Acceleration Data Buffer Filled!");
    
    NSDictionary *appDictionary=[[NSBundle mainBundle] infoDictionary];
    NSString *predictRequest=@"PredictOne"; //[appDictionary valueForKey:@"TeamFitPredictRequest"];
    
    NSMutableArray *downsampledGesture=[[NSMutableArray alloc] init];
    
    for(int i=0;i<numberOfFeatures*3;i++)
    {
        [downsampledGesture addObject:@(sampledGesture[i])];
    }
    
    //NSArray *downsampledGesture=[[NSArray alloc] initWith]
    
    NSDictionary *dataToSendToServer=@{@"feature": downsampledGesture,
                                       @"dsid":self.modelDataSetID,
                                       @"model":@"svm"};
    
    
    [self.ttWebServiceManager sendPost:dataToSendToServer to:predictRequest callback:^(NSData *data) {
        
        NSError *error=[[NSError alloc] init];
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        
        // we should get back the feature data from the server and the label it parsed
        NSString *prediction = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"prediction"]];

        if( [prediction isEqualToString:@"[u'Jumping Jack']"])
        {
            gestureTypeCount[0]++;
        }
        else if( [prediction isEqualToString:@"[u'Push Ups']"])
        {
            gestureTypeCount[1]++;
        }
        else if( [prediction isEqualToString:@"[u'Sit Ups']"])
        {
            gestureTypeCount[2]++;
        }
        else
        {
            gestureTypeCount[3]++;
        }
        
        NSLog(@"prediction : %@",prediction);
        
        NSString *result = [NSString stringWithFormat:@"prediction : %@",prediction];
        
        self.log = result;
        
//        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gestureRecognized:)])
//        {
//            //TFGesture *gesture=[[TFGesture alloc] init];
//            // TODO: add data to the gesture object
//            
//            //[self.delegate gestureRecognized:gesture];
//        }
    }];
    
}

- (void)update
{
 
    if(self.performUpdates)
    {
    
        // plot
        ringBufferX->FetchFreshData2(motionDataX, kBufferLength, 0, 1);
        ringBufferY->FetchFreshData2(motionDataY, kBufferLength, 0, 1);
        ringBufferZ->FetchFreshData2(motionDataZ, kBufferLength, 0, 1);
        
        SInt64 numberOfNewFrames = ringBufferVector->NumUnreadFrames();
        ringBufferVector->FetchFreshData2(motionVector, kBufferLength, 0, 1);
        
        //float* slidingWindowData=[self slidingWindow];
        
        float *motionVectorWindowed = new float[kBufferLength-windowSize+1];
        float *gestureDetectedVector = new float[kBufferLength-windowSize+1];
        
        for(int n=kBufferLength-windowSize;n>=0;n--)
        {
            motionVectorWindowed[n]=0;
            for(int p=n+windowSize-1;p>=n;p--)
            {
                motionVectorWindowed[n]+=motionVector[p];
            }
            
            motionVectorWindowed[n] = motionVectorWindowed[n]/windowSize;
            
            
            //gesture detection for plotting :D
            gestureDetectedVector[n]=0;
            if(motionVectorWindowed[n]>threshold)
            {
                gestureDetectedVector[n]=1;
            }
        }
        
        for(int n=(kBufferLength-windowSize)-numberOfNewFrames; n<kBufferLength-windowSize-1;n++)
        {
            if(!CurrentlyGesturing && n==((kBufferLength-windowSize)-numberOfNewFrames) && gestureDetectedVector[n]==1)
            {
                CurrentlyGesturing=YES;
                NSLog(@"Detected start Gesture at Start of New Frames");
                self.log = (@"Detected start Gesture at Start of New Frames");
                
                [self.delegate TFGestureRecognizerDidDetectBegin:self];
            }
            else if(CurrentlyGesturing && n==((kBufferLength-windowSize)-numberOfNewFrames) && gestureDetectedVector[n]==0)
            {
                CurrentlyGesturing=NO;
                NSLog(@"Detected End Gesture at Start of New Frames");
                self.log = (@"Detected End Gesture at Start of New Frames");
                [self.delegate TFGestureRecognizerDidDetectEnd:self];
                
                [self uploadGestureBuffer];
            }
            if(gestureDetectedVector[n]==0 && gestureDetectedVector[n+1]==1)
            {
                NSLog(@"Gesture Started");
                self.log = (@"Gesture Started");
                
                [self.delegate TFGestureRecognizerDidDetectBegin:self];
                
                CurrentlyGesturing=YES;
            }
            else if(gestureDetectedVector[n]==1 && gestureDetectedVector[n+1]==0)
            {
                NSLog(@"Gesture Started");
                self.log = (@"Gesture Started");
                [self.delegate TFGestureRecognizerDidDetectEnd:self];
                
                CurrentlyGesturing = NO;
                [self uploadGestureBuffer];
                
            }
            if(CurrentlyGesturing)
            {
                [self.gestureBuffer addObject:@(motionDataX[n+windowSize-1])];
                [self.gestureBuffer addObject:@(motionDataY[n+windowSize-1])];
                [self.gestureBuffer addObject:@(motionDataZ[n+windowSize-1])];
            }
        }
        
        delete [] motionVectorWindowed;
        delete [] gestureDetectedVector;
        
        dispatch_async(updatesQueue, ^{
            [NSThread sleepForTimeInterval:0.2];
            [self update];
        });
    }
}

-(void) updateTraining
{
    if(self.performUpdates)
    {
        // plot
        ringBufferX->FetchFreshData2(motionDataX, kBufferLength, 0, 1);
        ringBufferY->FetchFreshData2(motionDataY, kBufferLength, 0, 1);
        ringBufferZ->FetchFreshData2(motionDataZ, kBufferLength, 0, 1);
        
        SInt64 numberOfNewFrames = ringBufferVector->NumUnreadFrames();
        ringBufferVector->FetchFreshData2(motionVector, kBufferLength, 0, 1);
        
        //float* slidingWindowData=[self slidingWindow];
        
        float *motionVectorWindowed = new float[kBufferLength-windowSize+1];
        float *gestureDetectedVector = new float[kBufferLength-windowSize+1];
        
        for(int n=kBufferLength-windowSize;n>=0;n--)
        {
            motionVectorWindowed[n]=0;
            for(int p=n+windowSize-1;p>=n;p--)
            {
                motionVectorWindowed[n]+=motionVector[p];
            }
            
            motionVectorWindowed[n] = motionVectorWindowed[n]/windowSize;
            
            
            //gesture detection for plotting :D
            gestureDetectedVector[n]=0;
            if(motionVectorWindowed[n]>threshold)
            {
                gestureDetectedVector[n]=1;
            }
        }
        
        for(int n=(kBufferLength-windowSize)-numberOfNewFrames; n<kBufferLength-windowSize-1;n++)
        {
            if(!CurrentlyGesturing && n==((kBufferLength-windowSize)-numberOfNewFrames) && gestureDetectedVector[n]==1)
            {
                CurrentlyGesturing=YES;
                NSLog(@"Detected start Gesture at Start of New Frames");
                self.log = (@"Detected start Gesture at Start of New Frames");
                [self.delegate TFGestureRecognizerDidDetectBegin:self];
            }
            else if(CurrentlyGesturing && n==((kBufferLength-windowSize)-numberOfNewFrames) && gestureDetectedVector[n]==0)
            {
                CurrentlyGesturing=NO;
                NSLog(@"Detected End Gesture at Start of New Frames");
                self.log = (@"Detected End Gesture at Start of New Frames");
                //[self uploadGestureBuffer];
                [self.delegate TFGestureRecognizerDidDetectEnd:self];
                
            }
            if(gestureDetectedVector[n]==0 && gestureDetectedVector[n+1]==1)
            {
                NSLog(@"Gesture Started");
                self.log = (@"Gesture Started");
                CurrentlyGesturing=YES;
                [self.delegate TFGestureRecognizerDidDetectBegin:self];
            }
            else if(gestureDetectedVector[n]==1 && gestureDetectedVector[n+1]==0)
            {
                NSLog(@"Gesture Ended");
                self.log = (@"Gesture Ended");
                CurrentlyGesturing = NO;
                [self.delegate TFGestureRecognizerDidDetectEnd:self];
            }
            if(CurrentlyGesturing)
            {
                [self.gestureBuffer addObject:@(motionDataX[n+windowSize-1])];
                [self.gestureBuffer addObject:@(motionDataY[n+windowSize-1])];
                [self.gestureBuffer addObject:@(motionDataZ[n+windowSize-1])];
            }
        }
        
        delete [] motionVectorWindowed;
        delete [] gestureDetectedVector;
        
        dispatch_async(updatesQueue, ^{
            [NSThread sleepForTimeInterval:0.2];
            [self updateTraining];
        });
    }
}

-(void)uploadTrainingData:(NSInteger)datasetID withLabel:(NSString *)label
{
    if([self.gestureBuffer count] > 0)
    {
        NSLog(@"Gesture Buffer Count:%lu",(unsigned long)[self.gestureBuffer count]);
        if([self.gestureBuffer count] < numberOfFeatures*3)
        {
            [self.gestureBuffer removeAllObjects];
            self.gestureBuffer=nil;
            NSLog(@"Not enough gestures! Cancelling upload.");
            self.log=(@"Not enough gestures! Cancelling upload.");
            return;
        }
        [self downsampleGesture];
        [self.gestureBuffer removeAllObjects];
        self.gestureBuffer=nil;
        //SEND TO SERVER HERE
        
        NSLog(@"Acceleration Data Buffer Filled!");
        
        NSDictionary *appDictionary=[[NSBundle mainBundle] infoDictionary];
        NSString *predictRequest=@"AddDataPoint"; //[appDictionary valueForKey:@"TeamFitPredictRequest"];
        
        NSMutableArray *downsampledGesture=[[NSMutableArray alloc] init];
        
        for(int i=0;i<numberOfFeatures*3;i++)
        {
            [downsampledGesture addObject:@(sampledGesture[i])];
        }
        
        //NSArray *downsampledGesture=[[NSArray alloc] initWith]
        
        NSDictionary *dataToSendToServer=@{@"feature": downsampledGesture,
                                           @"dsid":self.modelDataSetID,
                                           @"label":label};
        
        
        [self.ttWebServiceManager sendPost:dataToSendToServer to:predictRequest callback:^(NSData *data) {
            
            NSError *error=[[NSError alloc] init];
            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
            
            // we should get back the feature data from the server and the label it parsed
            NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"feature"]];
            NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"label"]];
            NSLog(@"received %@ and %@",featuresResponse,labelResponse);
            
            self.log = [NSString stringWithFormat:@"received %@ and %@",featuresResponse,labelResponse ];
            
//            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gestureRecognized:)])
//            {
//                //TFGesture *gesture=[[TFGesture alloc] init];
//                // TODO: add data to the gesture object
//                
//                //[self.delegate gestureRecognized:gesture];
//            }
        }];

        
        
        NSLog(@"Gesture Done!");
    }
}

-(void)makeTrainingPrediction:(NSInteger)datasetID
{
    [self uploadGestureBuffer];
}

-(void) uploadGestureBuffer
{
    if([self.gestureBuffer count] > 0)
    {
        NSLog(@"Gesture Buffer Count:%lu",(unsigned long)[self.gestureBuffer count]);
        if([self.gestureBuffer count] < numberOfFeatures*3)
        {
            [self.gestureBuffer removeAllObjects];
            self.gestureBuffer=nil;
            NSLog(@"Not enough gestures! Cancelling upload.");
            self.log=(@"Not enough gestures! Cancelling upload.");
            return;
        }
        [self downsampleGesture];
        [self.gestureBuffer removeAllObjects];
        self.gestureBuffer=nil;
        [self uploadDownSampledGesture];
        
        NSLog(@"Gesture Done!");
    }
}
-(void) downsampleGesture
{
    
    float samplingRate = (([self.gestureBuffer count]-1)/3)/((float)numberOfFeatures);
    //NSLog(@"\n\nSampling Rate: %f\n", samplingRate);
    //NSLog(@"Downsampled: \n");
    for(int i=0; i<numberOfFeatures*3; i=i+3)
    {
        sampledGesture[i] = [self.gestureBuffer[((int) floorf((i*samplingRate)/3))*3] floatValue];
        sampledGesture[i+1] = [self.gestureBuffer[((int) floorf((i*samplingRate)/3))*3+1] floatValue];
        sampledGesture[i+2] = [self.gestureBuffer[((int) floorf((i*samplingRate)/3))*3+2] floatValue];
        //NSLog(@"%f, ",sampledGesture[i]);
    }
    NSLog(@"Completed Downsampling Gesture");
    return;
}

-(void) trainModel:(NSInteger)datasetID
{
    NSString *predictRequest=@"UpdateModel";
    NSDictionary *dataToSendToServer=@{@"dsid":self.modelDataSetID};
    
    [self.ttWebServiceManager sendGet:dataToSendToServer to:predictRequest callback:^(NSData *data) {
        NSLog(@"Train Model Response:");
        NSError *error=[[NSError alloc] init];
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        
        // we should get back the feature data from the server and the label it parsed
        NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"resubAccuracy_knn"]];
        NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"resubAccuracy_svm"]];
        
        
        NSString *result = [NSString stringWithFormat:@"knn %@, svm: %@",featuresResponse,labelResponse];
        
        NSLog(@"%@",result);

        self.log = result;
//        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(gestureRecognized:)])
//        {
//            //TFGesture *gesture=[[TFGesture alloc] init];
//            // TODO: add data to the gesture object
//            
//            //[self.delegate gestureRecognized:gesture];
//        }
    }];

}

@end
