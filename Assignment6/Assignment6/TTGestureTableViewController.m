//
//  TTGestureTableViewController.m
//  Assignment6
//
//  Created by install on 4/10/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TTGestureTableViewController.h"
#import "TTGesture.h"

#define SERVER_URL "http://teamhyperfit.cloudapp.net:8000"

@interface TTGestureTableViewController () <NSURLSessionTaskDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSNumber *dsid;

@property (nonatomic, strong) NSMutableArray* gestures;

@end

@implementation TTGestureTableViewController


- (NSMutableArray *) gestures
{
    if (!_gestures){
        _gestures = [[NSMutableArray alloc] init];
    }
    return _gestures;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

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
}

- (IBAction)OnUIDButtonPressed:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"User ID";
    alert.message = @"Please enter User ID";
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)getGestureListFromServer
{
    NSString *baseURL = [NSString stringWithFormat:@"%s/GetLabelList?dsid=%@",SERVER_URL,self.dsid];
    
    NSURL *getUrl = [NSURL URLWithString:baseURL];
    NSURLSessionTask *theTask = [self.session dataTaskWithURL:getUrl
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                     if (!error) {
                                         NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                         
                                         [self.gestures removeAllObjects];
                                         
                                         for( id item in responseData[@"labels"])
                                         {
                                             TTGesture *gesture = [[TTGesture alloc] init];
                                             gesture.name = [NSString stringWithFormat:@"Gesture%@", item];
                                             [self.gestures addObject:gesture];
                                         }
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.tableView reloadData];
                                         });
                                     }
                                     else
                                     {
                                         NSLog(@"%@", error);
                                     }
                                 }];
    
    [theTask resume];
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UITextField *gestureTextField = [alertView textFieldAtIndex:0];
	self.dsid = @(gestureTextField.text.intValue);
    
    [self getGestureListFromServer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gestures.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.gestures[indexPath.row] name];
    
    return cell;
}


#pragma mark - TTMotionCaptureDelegate
- (void)didCaptureNewMotion:(TTGesture *)capturedGesture
{
	if ( capturedGesture )
	{
		[self.gestures addObject:capturedGesture];
		[self.tableView reloadData];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"MotionCaptureSegue"])
	{
		TTMotionCaptureViewController *motionCaptureViewController = segue.destinationViewController;
		motionCaptureViewController.delegate = self;
        motionCaptureViewController.GID = (int)self.gestures.count;
        motionCaptureViewController.dsid = self.dsid;
	}
}

@end
