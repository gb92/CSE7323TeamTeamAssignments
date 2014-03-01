//
//  TMSetGoalStepViewController.m
//  TeamFit
//
//  Created by Mark Wang on 2/27/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMSetGoalStepViewController.h"


@interface TMSetGoalStepViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *goalPicker;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;

- (IBAction)cancelPress:(id)sender;
- (IBAction)setPressed:(id)sender;

@property (nonatomic, readwrite) unsigned int newStepGoal;


@end

@implementation TMSetGoalStepViewController


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld",(long)row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.newStepGoal = [self getValueFromPicker];
    [self.goalLabel setText:[NSString stringWithFormat:@"%d",self.newStepGoal]  ];
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
	
    self.goalPicker.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.goalLabel setText:[NSString stringWithFormat:@"%d",self.currentGoal]  ];
    self.newStepGoal = self.currentGoal;

}

-(void)viewDidAppear:(BOOL)animated
{
    [self setValueToPicker:self.currentGoal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelPress:(id)sender
{
    [self.delegate SetGoalSetpViewControllerDidCancel:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setPressed:(id)sender
{
    
    [self.delegate SetGoalSetpViewControllerDidSet:self newGoal:self.newStepGoal];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-----------------------------------*/
-(void)setValueToPicker:( unsigned int )value
{
    for( int i=4; i>=0; i-- )
    {
        unsigned int divider = pow(10, i);
        unsigned int tempValue = value / divider;
        value %= divider;
        
        [self.goalPicker selectRow:tempValue inComponent:(4-i) animated:YES];
    }
}

-(unsigned int) getValueFromPicker
{
    unsigned int result = 0;
    
    result = (unsigned int)( [self.goalPicker selectedRowInComponent:4] +
    [self.goalPicker selectedRowInComponent:3] * 10 +
    [self.goalPicker selectedRowInComponent:2] * 100 +
    [self.goalPicker selectedRowInComponent:1] * 1000 +
    [self.goalPicker selectedRowInComponent:0] * 10000 );
    
    return result;
}

@end
