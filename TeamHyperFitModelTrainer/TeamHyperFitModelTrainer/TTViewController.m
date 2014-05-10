//
//  TTViewController.m
//  TeamHyperFitModelTrainer
//
//  Created by Gavin Benedict on 5/9/14.
//  Copyright (c) 2014 edu.smu.cse7323. All rights reserved.
//

#import "TTViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "TFGestureRecognizer.h"

@interface TTViewController ()
@property (weak, nonatomic) IBOutlet UIButton *gestureStartStopButton;

@property (weak, nonatomic) IBOutlet UIPickerView *gesturePicker;

@property (strong, nonatomic) TFGestureRecognizer *gestureRecognizer;

@property (strong, nonatomic) NSString *gestureLabel;

@property NSInteger rowSelected;

@end

@implementation TTViewController

-(TFGestureRecognizer *) gestureRecognizer
{
    if(_gestureRecognizer == nil)
    {
        _gestureRecognizer=[[TFGestureRecognizer alloc] init];
    }
    
    return _gestureRecognizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.gesturePicker.dataSource=self;
    self.gesturePicker.delegate=self;
    
    self.gestureLabel=@"Jumping Jack";
    self.rowSelected=0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(row == 0)
    {
        return @"Jumping Jack";
    }
    else if(row == 1)
    {
        return @"Push Ups";
    }
    else if(row == 2)
    {
        return @"Sit Ups";
    }
    else if(row ==3)
    {
        return @"Squats";
    }
    else
    {
        return @"Error";
    }
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.rowSelected=row+5;
    NSLog(@"Row Selected: %ld", self.rowSelected);
    
    if(row == 0)
    {
        self.gestureLabel=@"Jumping Jack";
    }
    else if(row == 1)
    {
        self.gestureLabel= @"Push Ups";
    }
    else if(row == 2)
    {
        self.gestureLabel= @"Sit Ups";
    }
    else if(row ==3)
    {
        self.gestureLabel= @"Squats";
    }
    else
    {
        self.gestureLabel= @"Error";
    }
    
}


- (IBAction)startStopGesturePressed:(id)sender {
    
    if([self.gestureStartStopButton.currentTitle isEqual:@"Start Gesture"])
    {
        [self.gestureStartStopButton setTitle:@"Stop Gesture" forState:UIControlStateNormal];
        [self.gestureRecognizer startTrainingGestureCapture];
    }
    else
    {
        //stop recording gesture
        [self.gestureStartStopButton setTitle:@"Start Gesture" forState:UIControlStateNormal];
        [self.gestureRecognizer stopGestureCapture];
    }
}

- (IBAction)uploadGesturePressed:(id)sender {
    
    [self.gestureRecognizer uploadTrainingData:self.rowSelected withLabel:self.gestureLabel];
}

- (IBAction)predictGesturePressed:(id)sender {
    [self.gestureRecognizer makeTrainingPrediction:self.rowSelected];
    
}

- (IBAction)trainModelPressed:(id)sender {
    [self.gestureRecognizer trainModel:self.rowSelected];
}

@end
