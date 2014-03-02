//
//  TMStairSettingViewController.m
//  TeamFit
//
//  Created by Mark Wang on 3/1/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMStairSettingViewController.h"

@interface TMStairSettingViewController ()
- (IBAction)onSetButtonPressed:(id)sender;
- (IBAction)onCancelButtonPressed:(id)sender;
- (IBAction)onThresholdChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UILabel *thresholdLabel;
@property (nonatomic) float currentThreshold;
@end

@implementation TMStairSettingViewController

-(void)currentThreshold:(float)value
{
    if (value < -1.0)
    {
        _currentThreshold = -1.0f;
    }
    else if( value > 0.0)
    {
        _currentThreshold = 0.0;
    }
    else
    {
        _currentThreshold = value;
    }
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
}

-(void)viewWillAppear:(BOOL)animated
{
    self.thresholdSlider.value = self.currentThreshold;
    self.thresholdLabel.text = [NSString stringWithFormat:@"%.2f",self.thresholdSlider.value];
}


-(void)setThresholdValue:(float)value
{
     self.currentThreshold = value;
}

- (IBAction)onSetButtonPressed:(id)sender
{
    [self.delegate TMStairSettingViewControllerSetButtonPressed:self
                                             withThresholdValue:self.thresholdSlider.value];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onCancelButtonPressed:(id)sender
{
    [self.delegate TMStairSettingViewControllerCancelButtonPressed:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onThresholdChanged:(id)sender
{
    self.thresholdLabel.text = [NSString stringWithFormat:@"%.2f",self.thresholdSlider.value];
}
@end
