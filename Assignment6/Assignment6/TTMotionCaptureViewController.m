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
#define UPDATE_INTERVAL 1/10.0

@interface TTMotionCaptureViewController ()<UIAlertViewDelegate , NSURLSessionTaskDelegate>

@property (strong,nonatomic) CMMotionManager *cmMotionManager;
@property (strong, nonatomic ) RingBuffer *ringBuffer;

// for the machine learning session
@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSNumber *dsid;
@property (atomic) BOOL isWaitingForInputData;

- (IBAction)onPredictButtonPressed:(UIButton *)sender;
@end

@implementation TTMotionCaptureViewController
{
    dispatch_queue_t motionCaptureQueue;
    bool bCollecting;
    int count;
}

- (IBAction)onPredictButtonPressed:(UIButton *)sender
{
    [self predictFeature:self.ringBuffer.getDataAsVector ];
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

-(void) startMotionUpdates{
    
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
             
//             float dotProduct =
//             motion.gravity.x*motion.userAcceleration.x +
//             motion.gravity.y*motion.userAcceleration.y +
//             motion.gravity.z*motion.userAcceleration.z;
            
             [self.ringBuffer addNewData:motion.userAcceleration.x withY:motion.userAcceleration.y withZ:motion.userAcceleration.z ];
             
             NSLog(@"x : %f", motion.userAcceleration.x );
             
         }];
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

- (IBAction)onCapturingButtonUp:(UIButton *)sender
{
    
    [self deactivate];
    [self sendFeatureArray:[self.ringBuffer getDataAsVector] withLabel:@(1) ];
    [self updateModel];
    
//    bCollecting=false;
	
//	UIAlertView *alert = [UIAlertView new];
//	alert.title = @"Motion Name";
//	alert.message = @"Please enter the Gesture's Name:";
//	alert.delegate = self;
//	[alert addButtonWithTitle:@"OK"];
//	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//	[alert show];
}


- (IBAction)onCapturedButtonDown:(id)sender {
  
    
    [self activate];
    
//    bCollecting= true;
    
//    dispatch_async(motionCaptureQueue, ^{
//        
//        
//        while(bCollecting)
//        {
//             NSLog(@"Second One %d", count);
//		}
//        
//    });
    
}

- (IBAction)onCapturingButtonHold:(UIButton *)sender
{
    NSLog(@"I work");
}

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
    
    [self getDataSetId];
    
}

-(void)viewWillAppear:(BOOL)animated
{

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self deactivate];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UITextField *gestureTextField = [alertView textFieldAtIndex:0];
	TTGesture *capturedGesture = [TTGesture new];
	capturedGesture.name = gestureTextField.text;
	
	if (self.delegate)
	{
		[self.delegate didCaptureNewMotion:capturedGesture];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
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
                                                         NSLog(@"Accuracy using resubstitution: %@",responseData[@"resubAccuracy"]);
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
                                                             NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
                                                             
                                                             NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"prediction"]];
                                                             NSLog(@"%@",labelResponse);
                                                             NSLog(@"result : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                             
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 // flash the view that was touched
                                                                 if([labelResponse  isEqual: @"[0]"])
                                                                     NSLog(@"%@", labelResponse);
                                                                 else if([labelResponse  isEqual: @"[1]"])
                                                                     NSLog(@"%@", labelResponse);
                                                                 else if([labelResponse  isEqual: @"[2]"])
                                                                     NSLog(@"%@", labelResponse);
                                                                 else if([labelResponse  isEqual: @"[3]"])
                                                                     NSLog(@"%@", labelResponse);
                                                                 
                                                                 self.isWaitingForInputData = YES;
                                                             });
                                                         }
                                                     }];
    [postTask resume];
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
                                                             
                                                             // we should get back the feature data from the server and the label it parsed
                                                             NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"feature"]];
                                                             NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"label"]];
                                                             NSLog(@"received %@ and %@",featuresResponse,labelResponse);
                                                         }
                                                     }];
    [postTask resume];
    
}


@end
