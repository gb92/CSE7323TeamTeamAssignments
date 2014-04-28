//
//  TTMotionCaptureViewController.m
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTMotionCaptureViewController.h"
#import <CoreMotion/CoreMotion.h>

#import "TTGesture.h"
#import "RingBuffer.h"

#define SERVER_URL "http://teamhyperfit.cloudapp.net:8000"


@interface TTMotionCaptureViewController ()<UIAlertViewDelegate , NSURLSessionTaskDelegate>

@property (strong,nonatomic) CMMotionManager *cmMotionManager;
@property (strong, nonatomic ) RingBuffer *ringBuffer;

// for the machine learning session
@property (strong,nonatomic) NSURLSession *session;
@property (atomic) BOOL isWaitingForInputData;


@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gestureNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *trainingModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) TTGesture *gesture;
@property (nonatomic) BOOL haveTrained;
@property (nonatomic) BOOL isSVM;
@end

@implementation TTMotionCaptureViewController
{
    dispatch_queue_t motionCaptureQueue;
    bool bCollecting;
    BOOL isTrained;
    BOOL isCapturing;
    
    int predictionCount[2];
}

#pragma makr - Instantiation

-(TTGesture*) gesture
{
    if(!_gesture)
    {
        _gesture = [[TTGesture alloc] init];
        _gesture.name = [NSString stringWithFormat:@"Gesture%d", self.GID];
    }
    
    return _gesture;
}

-(RingBuffer*)ringBuffer
{
    if(!_ringBuffer)
    {
        _ringBuffer = [[RingBuffer alloc] init];
    }
    
    return _ringBuffer;
}

-(CMMotionManager*)cmMotionManager
{
    if(!_cmMotionManager){
        _cmMotionManager = [[CMMotionManager alloc] init];
        
        if(![_cmMotionManager isDeviceMotionAvailable]){
            _cmMotionManager = nil;
        }
    }
    return _cmMotionManager;
    
}

#pragma mark - control callback

- (IBAction)EditGestureName:(id)sender
{
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"Motion Name";
    alert.message = @"Please enter the Gesture's Name:";
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
- (IBAction)onTrainModelChanged:(UISwitch *)sender
{
    self.isSVM = [sender isOn];
    if( self.isSVM )
    {
        self.trainingModelLabel.text = @"SVM";
    }
    else
    {
        self.trainingModelLabel.text = @"KNN";
    }
}

- (IBAction)onTrainSwitched:(UISwitch *)sender
{
    isTrained = [sender isOn];
    if( isTrained )
    {
        self.modeLabel.text = @"Training Mode";
    }
    else
    {
        self.modeLabel.text = @"Testing Mode";
    }
}

- (IBAction)onBackButtonPressed:(UIBarButtonItem *)sender
{

	if (self.delegate)
	{
        if( self.haveTrained )
            [self.delegate didCaptureNewMotion:self.gesture];
        else
            [self.delegate didCaptureNewMotion:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
	}

}

- (IBAction)onCapturingButtonUp:(UIButton *)sender
{
    
    [self deactivate];
    
    if (isTrained)
    {
        [self sendFeatureArray:[self.ringBuffer getDataAsVector] withLabel:@(self.GID) ];
        [self updateModel];
    }
    else
    {
        [self predictFeature:self.ringBuffer.getDataAsVector];
    }
}


- (IBAction)onCapturedButtonDown:(id)sender {
    
    
    [self activate];
    
}

- (IBAction)onCapturingButtonHold:(UIButton *)sender
{
    //NSLog(@"I work");
}

#pragma mark - View Delegation

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    motionCaptureQueue = dispatch_queue_create("edu.smu.TeamTeam.MotionCapture", NULL);
    
    // Do any additional setup after loading the view.
    //setup NSURLSession (ephemeral)
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.timeoutIntervalForResource = 8.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    isTrained = YES;
    self.haveTrained = NO;
    self.isSVM = YES;
    
    isCapturing = NO;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.gestureNameLabel.text = self.gesture.name;
    
    [self startMotionUpdates];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self deactivate];
}

#pragma mark - Motion Control

-(void) startMotionUpdates{
    
    if(self.cmMotionManager)
    {
        if (![self.cmMotionManager isDeviceMotionActive]) {
            [self.cmMotionManager startDeviceMotionUpdates];
        }
        
        NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
        myQueue.maxConcurrentOperationCount = 1;
        
        __weak typeof(self) weakSelf = self;
        
        [self.cmMotionManager setDeviceMotionUpdateInterval:1.0/100.0];
        [self.cmMotionManager
         startDeviceMotionUpdatesToQueue:myQueue
         withHandler:^(CMDeviceMotion *motion, NSError *error) {
            
//             
//             float dotProduct =
//             motion.gravity.x*motion.userAcceleration.x +
//             motion.gravity.y*motion.userAcceleration.y +
//             motion.gravity.z*motion.userAcceleration.z;
//             
//             dotProduct /= motion.gravity.x*motion.gravity.x +
//             motion.gravity.y*motion.gravity.y +
//             motion.gravity.z*motion.gravity.z;
             
             float length = (motion.userAcceleration.x * motion.userAcceleration.x) +
             (motion.userAcceleration.y * motion.userAcceleration.y) +
             (motion.userAcceleration.z * motion.userAcceleration.z);
             
//             float lengthOfRotation = (motion.rotationRate.x * motion.rotationRate.x) +
//             (motion.rotationRate.y * motion.rotationRate.y) +
//             (motion.rotationRate.z * motion.rotationRate.z);
             
             length = sqrtf(length);
             
             if(length > 0.4)
             {
                 if( !isCapturing )
                 {
                      dispatch_async(dispatch_get_main_queue(),^{
                         [weakSelf beginCapture];
                     });
                     
                 }
             }

            if( isCapturing )
            {
                [self.ringBuffer addNewData:motion.userAcceleration.x
                                           withY:motion.userAcceleration.y
                                           withZ:motion.userAcceleration.z ];
            }
             

         }];
    }
}

-(void)beginCapture
{
    isCapturing = YES;
    [self performSelector:@selector(doneCapture) withObject:nil afterDelay:1];
    
    NSLog(@"Begin Capuring");
}
-(void)doneCapture
{
    isCapturing = NO;
    //! Send data to server and predict it.
    NSLog(@"Done Capuring");
    if (isTrained)
    {
        [self sendFeatureArray:[self.ringBuffer getDataAsVector] withLabel:@(self.GID) ];
        [self updateModel];
    }
    else
    {
        [self predictFeature:self.ringBuffer.getDataAsVector];
    }
}

-(void)activate
{
    [self startMotionUpdates];
}

-(void)deactivate
{
    if ([self.cmMotionManager isDeviceMotionActive]) {
        [self.cmMotionManager stopDeviceMotionUpdates];
    }
}


#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UITextField *gestureTextField = [alertView textFieldAtIndex:0];
	self.gestureNameLabel.text = gestureTextField.text;
}

#pragma mark - HTTP Post and Get Request Methods
- (void)getDataSetId
{
    
    // get a new dataset ID from the server (gives back a new dataset id)
    // Note that if data is not uploaded, the server may issue the same dsid to another requester
    // ---how might you solve this problem?---
    
    // create a GET request and get the reponse back as NSData
    NSString *baseURL = [NSString stringWithFormat:@"%s/GetNewDatasetId",SERVER_URL];
    
    NSURL *getUrl = [NSURL URLWithString: baseURL];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:getUrl
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error) {
                                                     if(!error){
                                                         NSLog(@"%@",response);
                                                         NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                         self.dsid = responseData[@"dsid"];
                                                         NSLog(@"New dataset id is %@",self.dsid);
                                                         
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             NSLog( @"DSID: %ld",(long)[self.dsid integerValue]);
                                                         });
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"error : %@", error);
                                                     }
                                                     
                                                     
                                                 }];
    [dataTask resume]; // start the task
    
}


- (void)sendFeatureArray:(NSArray*)data
               withLabel:(NSNumber*)label
{
    // Add a data point and a label to the database for the current dataset ID
    
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/AddDataPoint",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    
    // make an array of feature data
    // and place inside a dictionary with the label and dsid
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"feature":data,
                                 @"label":label,
                                 @"dsid":self.dsid};
    
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         if(!error){
                                                             NSLog(@"%@",response);
                                                             NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                             
                                                             self.haveTrained = YES;
                                                             // we should get back the feature data from the server and the label it parsed
                                                             NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"feature"]];
                                                             NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"label"]];
                                                             NSLog(@"received %@ and %@",featuresResponse,labelResponse);
                                                         }
                                                     }];
    [postTask resume];
    
}

- (void)updateModel
{
    // tell the server to train a new model for the given dataset id (dsid)
    
    // create a GET request and get the reponse back as NSData
    NSString *baseURL = [NSString stringWithFormat:@"%s/UpdateModel",SERVER_URL];
    NSString *query = [NSString stringWithFormat:@"?dsid=%d",[self.dsid intValue]];
    
    NSURL *getUrl = [NSURL URLWithString: [baseURL stringByAppendingString:query]];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:getUrl
                                                 completionHandler:^(NSData *data,
                                                                     NSURLResponse *response,
                                                                     NSError *error) {
                                                     if(!error){
                                                         // we should get back the accuracy of the model
                                                         NSLog(@"%@",response);

                                                         NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                         
                                                         if (responseData) {
                                                             NSLog(@"Accuracy using resubstitution [SVM: %@] [KNN: %@]",responseData[@"resubAccuracy_svm"], responseData[@"resubAccuracy_knn"]);
                                                             
                                                             float accSVM = [responseData[@"resubAccuracy_svm"] floatValue];
                                                             float accKNN = [responseData[@"resubAccuracy_knn"] floatValue];
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 if ( accSVM > accKNN )
                                                                     self.resultLabel.text = [NSString stringWithFormat:@"SVM>knn Acc : %f", (accSVM-accKNN)];
                                                                 else
                                                                     self.resultLabel.text = [NSString stringWithFormat:@"KNN>svm : %f", (accKNN-accSVM)];
                                                                 
                                                                 self.isWaitingForInputData = YES;
                                                             });
                                                         }

                                                     }
                                                 }];
    [dataTask resume]; // start the task
}

- (void)predictFeature:(NSArray*)featureData
{
    // send the server new feature data and request back a prediction of the class
    
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/PredictOne",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    
    // data to send in body of post request (send arguments as json)
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"feature":featureData,
                                 @"dsid":self.dsid,
                                 @"model": (self.isSVM)?@"svm":@"knn" };
    
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         if(!error){
                                                             NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                             
                                                             if (responseData) {
                                                                 
                                                                 NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"prediction"]];
                                                                 NSLog(@"%@",labelResponse);
                                                                 NSLog(@"result : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                                 
                                                                 if ([labelResponse isEqualToString:@"[0]"]) {
                                                                     predictionCount[0]++;
                                                                 }
                                                                 else
                                                                 {
                                                                     predictionCount[1]++;
                                                                 }
                                                                 
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     
                                                                     self.resultLabel.text = [NSString stringWithFormat:@"Result = Gesture%@", labelResponse];
                                                                     
                                                                     self.isWaitingForInputData = YES;
                                                                     
                                                                     self.countLabel.text = [NSString stringWithFormat:@"%d",predictionCount[0]];
                                                                 });
                                                             }

                                                         }
                                                     }];
    [postTask resume];
}



@end
