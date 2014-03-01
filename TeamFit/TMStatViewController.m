//
//  TMStatViewController.m
//  TeamFit
//
//  Created by Mark Wang on 2/28/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMStatViewController.h"

@interface TMStatViewController ()
- (IBAction)onBackButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *yesterdayStepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStepsLabel;

@end

@implementation TMStatViewController
{
    int currentStep;
}

-(void)setCurrentStep:(int)value
{
    currentStep = value;
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
    
    //@TODO Set Yesterday step here!!
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
