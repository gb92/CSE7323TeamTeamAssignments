//
//  TTMainViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTMainViewController.h"
#import "TTSevenDaysView.h"
#import "TMStepCountViewController.h"

@interface TTMainViewController ()

@property (weak, nonatomic) IBOutlet TTSevenDaysView *sunView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *monView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *tueView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *wesView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *thuView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *friView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *satView;

@property (weak, nonatomic) IBOutlet TMStepIndicaterView *fitpointView;

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;

@end

@implementation TTMainViewController

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
    
    self.sunView.text = @"S";
    self.monView.text = @"M";
    self.tueView.text = @"T";
    self.wesView.text = @"W";
    self.thuView.text = @"Th";
    self.friView.text = @"F";
    self.satView.text = @"Sa";
    
    [self.sunView setStepValue:60];
    [self.monView setStepValue:55];
    [self.tueView setStepValue:89];
    [self.wesView setStepValue:20];
    [self.thuView setStepValue:0];
    [self.friView setStepValue:10];
    [self.satView setStepValue:35];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
