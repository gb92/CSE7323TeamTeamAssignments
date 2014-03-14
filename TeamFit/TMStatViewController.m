///Users/redeian/Documents/Xcode Project/GavinGitHub/TeamFit/TeamFit/TMStairSettingViewController.m
//  TMStatViewController.m
//  TeamFit
//
//  Created by Mark Wang on 2/28/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMStatViewController.h"

@interface TMStatViewController ()

@property (weak, nonatomic) IBOutlet UILabel *yesterdayStepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStepsLabel;

@end

@implementation TMStatViewController
{
    int currentStep;
    int yesterdayStep;
}

-(void)setCurrentStep:(int)value
{
    currentStep = value;
}

-(void)setYesterdayStep:(int)value
{
    yesterdayStep = value;
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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.currentStepsLabel setText:[NSString stringWithFormat:@"%d", currentStep]];
    [self.yesterdayStepsLabel setText:[NSString stringWithFormat:@"%d", yesterdayStep]];
}

@end
