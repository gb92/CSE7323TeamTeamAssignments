//
//  TMSetGoalStepViewController.m
//  TeamFit
//
//  Created by Chatchai Wangwiwiwattana on 2/27/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMSetGoalStepViewController.h"

static const int PICKER_COMPONENT = 6;

@interface TMSetGoalStepViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *goalPicker;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;


@property (nonatomic, readwrite) unsigned int newStepGoal;


@end

@implementation TMSetGoalStepViewController


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return PICKER_COMPONENT;
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
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)setPressed:(id)sender
{
    
    [self.delegate SetGoalSetpViewControllerDidSet:self newGoal:self.newStepGoal];
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/*-----------------------------------*/
-(void)setValueToPicker:( unsigned int )value
{
    for( int i=PICKER_COMPONENT-1; i>=0; i-- )
    {
        unsigned int divider = pow(10, i);
        unsigned int tempValue = value / divider;
        value %= divider;
        
        [self.goalPicker selectRow:tempValue inComponent:(PICKER_COMPONENT-(i+1)) animated:YES];
    }
}

-(unsigned int) getValueFromPicker
{
    unsigned int result = 0;
    
    for( int i=0; i<PICKER_COMPONENT; i++ )
    {
        unsigned int multiplier = pow(10, i );
        result += [self.goalPicker selectedRowInComponent: (PICKER_COMPONENT - (i+1)) ] * multiplier;
    }
    
    return result;
}

@end
