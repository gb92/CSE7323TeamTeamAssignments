//
//  TTViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTViewController.h"
#import "TTWebServiceManager.h"
#import "TTAppDelegate.h"

@interface TTViewController ()
@property (strong, nonatomic) TTWebServiceManager* webServiceManager;
@end

@implementation TTViewController


#pragma mark -- initialization

-(TTWebServiceManager*) webServiceManager
{
    TTAppDelegate* appDelegate = (TTAppDelegate*) [[UIApplication sharedApplication] delegate];
    return appDelegate.webServiceManager;
}

#pragma mark -- VC life cicle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
