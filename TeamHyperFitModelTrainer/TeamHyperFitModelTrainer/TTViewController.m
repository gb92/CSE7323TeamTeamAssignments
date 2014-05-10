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
@property (weak, nonatomic) IBOutlet UITextView *resultTextField;

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
    
    [self.gestureRecognizer addObserver:self forKeyPath:@"log" options:NSKeyValueObservingOptionNew context:nil];
    
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"log"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            
        self.resultTextField.text = self.gestureRecognizer.log;
        
        });
        
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
    self.gestureRecognizer.modelDataSetID = @(22);
    [self.gestureRecognizer uploadTrainingData:22 withLabel:self.gestureLabel];
}

- (IBAction)predictGesturePressed:(id)sender {
    self.gestureRecognizer.modelDataSetID = @(22);
    [self.gestureRecognizer makeTrainingPrediction:22];
    
}

- (IBAction)trainModelPressed:(id)sender {
    self.gestureRecognizer.modelDataSetID = @(22);
    [self.gestureRecognizer trainModel:22];
}

@end