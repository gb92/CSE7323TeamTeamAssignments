//
//  TTSettingTableViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/5/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSettingTableViewController.h"
#import "TTAppDelegate.h"
#import "TFGestureRecognizer.h"

#import <FacebookSDK/FacebookSDK.h>

#define MIN_AGE 7
#define AGE_RANGE 50

@interface TTSettingTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;
@property (strong, nonatomic) TFGestureRecognizer *gestureRecognizer;


@property (weak, nonatomic) IBOutlet UIPickerView *agePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *trainingDatasetPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *heartRateSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *trainingModelSegment;


@end

@implementation TTSettingTableViewController

-(TFGestureRecognizer*)gestureRecognizer
{
    if (!_gestureRecognizer) {
        _gestureRecognizer = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).gestrueRecognizer;
    }
    
    return _gestureRecognizer;
}

-(TTUserInfoHandler*)userInfoHandler
{
    if(!_userInfoHandler)
    {
        _userInfoHandler = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userInforHandler;
        
    }
    
    return _userInfoHandler;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*Example */
    /*
    self.settingModel.isHeartRateEnable = YES;
    
    self.userInfoHandler.userInfo.age = 10;
    self.userInfoHandler.userInfo.gender = @"male"; //@"female"
    */
	[self.agePickerView selectRow:(self.userInfoHandler.userInfo.age)
					  inComponent:0
						 animated:NO];
	
	[self.genderSegment setSelectedSegmentIndex:
     ([[self.userInfoHandler.userInfo.gender lowercaseString]
       isEqualToString:@"male"]) ? 0 : 1 ];
    
	
	[self.trainingModelSegment setSelectedSegmentIndex:self.gestureRecognizer.gestureModelMode == TM_MODEL_KNN ? 0 : 1];
	
	[self.trainingDatasetPickerView selectRow:[self.gestureRecognizer.modelDataSetID intValue]
								  inComponent:0
									 animated:NO];
	
#warning it is error prone. Please change.
    [[NSUserDefaults standardUserDefaults] boolForKey:@"heartRateEnable"];
	self.heartRateSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"heartRateEnable"];
}

#pragma mark - Handling actions

- (IBAction)onCloseButtonPressed:(id)sender
{
#warning it is error prone. Please change.
    [[NSUserDefaults standardUserDefaults] setBool:self.heartRateSwitch.on forKey:@"heartRateEnable"];
	
    self.gestureRecognizer.gestureModelMode = [self.trainingModelSegment selectedSegmentIndex] == 0 ? TM_MODEL_KNN : TM_MODEL_SVM;
	self.gestureRecognizer.modelDataSetID = @([self.trainingDatasetPickerView selectedRowInComponent:0]);
	self.userInfoHandler.userInfo.age = [self.agePickerView selectedRowInComponent:0];
	self.userInfoHandler.userInfo.gender = [self.genderSegment selectedSegmentIndex] == 0 ? @"male" : @"female";
	
    [[NSUserDefaults standardUserDefaults] setInteger:self.userInfoHandler.userInfo.age forKey:@"age"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userInfoHandler.userInfo.gender forKey:@"gender"];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - Pciker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
	if (pickerView.tag == 0) // age picker
	{
		return AGE_RANGE;
	}
	else if (pickerView.tag == 1) // gender picker
	{
		return 2;
	}
	else if (pickerView.tag == 2) // training model picker
	{
		return 2;
	}
	else if (pickerView.tag == 3) // training dataset id picker
	{
		return 51;
	}
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (pickerView.tag == 0) // age picker
	{
		return [NSString stringWithFormat:@"%ld", row + MIN_AGE];
	}
	else if (pickerView.tag == 1) // gender picker
	{
		return row == 0 ? @"Male" : @"Female";
	}
	else if (pickerView.tag == 2) // training model picker
	{
		return row == 0 ? @"KNN" : @"SVM";
	}
	else if (pickerView.tag == 3) // training dataset id picker
	{
		return [NSString stringWithFormat:@"%ld", (long)row];
	}
	
	return @"";
}

@end
