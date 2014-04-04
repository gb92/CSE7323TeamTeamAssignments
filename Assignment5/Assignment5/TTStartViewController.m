//
//  TTStartViewController.m
//  Assignment5
//
//  Created by Mark Wang on 4/4/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTStartViewController.h"
#import "TTAppDelegate.h"
#import "TTConnectingTableView.h"

@interface TTStartViewController ()

@property (strong, nonatomic, readonly) BLE *bleShield;

@end

@implementation TTStartViewController

-(BLE*)bleShield
{
    TTAppDelegate *appDelegate = (TTAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.bleShield;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(delayBeforeSearch:) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)delayBeforeSearch:(NSTimer*)timer
{
    [self.bleShield findBLEPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(searchForDevices:) userInfo:nil repeats:NO];
}

-(void)searchForDevices:(NSTimer*) timer
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TTConnectingTableView *connectingTableView = [storyboard instantiateViewControllerWithIdentifier:@"deviceTable"];
    [connectingTableView setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:connectingTableView animated:YES completion:nil];
}

@end
