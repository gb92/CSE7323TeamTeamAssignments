//
//  TTControllerViewController.m
//  Assignment5
//
//  Created by ch484-mac5 on 3/31/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTControllerViewController.h"

@interface TTControllerViewController ()


@end

@implementation TTControllerViewController

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
	// Do any additional setup after loading the view.
    
    [self.deviceNameLabel setText:self.deviceName];
    
    NSLog(@"%@", self.CVCData);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
