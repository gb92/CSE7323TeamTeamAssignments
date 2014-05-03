//
//  TTStatusViewController.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTStatusViewController.h"
#import "TTGraphView.h"
#import "TTActionTableViewCell.h"
#import "TTCaptureScreenShot.h"
#import "TTInfoViewController.h"

#import "TFUserModel.h"
#import "TTAppDelegate.h"

#import "UICountingLabel.h"

@interface TTStatusViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UICountingLabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UICountingLabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UITableView *actionTableView;
@property (weak, nonatomic) IBOutlet TTGraphView *fitpointGraphView;

@property (strong, nonatomic) TFUserModel* userModel;

@end

@implementation TTStatusViewController

-(TFUserModel*)userModel
{
    if (!_userModel) {
        _userModel = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userModel;
    }
    
    return _userModel;
}

#pragma mark -
#pragma mark View Life Cycle.

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
    
    self.actionTableView.dataSource = self;
    self.actionTableView.delegate = self;
    
    //! Show graph only 2 weeks
    self.fitpointGraphView.numberOfColumn = @(14);
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self.delegate TTStatusViewControllerOnCloseButtonPressed:self];
}

#pragma mark -
-(void)updateInfo
{
    //! Fake Data for now.
    self.fitpointGraphView.data = [[NSArray alloc] initWithObjects:@(1),@(5),@(2),@(4),@(6),@(5),@(3),@(0),@(10),@(6),@(7),@(5), nil];
    
    self.stepsLabel.format = @"%d";
    self.stepsLabel.method = UILabelCountingMethodEaseIn;
    [self.stepsLabel countFrom:0 to:9854762 withDuration:0.5f];
    
    self.calorieLabel.format = @"%d";
    self.calorieLabel.method = UILabelCountingMethodEaseIn;
    [self.calorieLabel countFrom:0 to:9854762 withDuration:0.7f];
}

#pragma mark --Table View Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
    
    cell.actionNameLabel.text = @"PUSH-UPS";
    cell.numberOfRepsLabel.text = @"1,000 reps";
    cell.actionImageView.image = [UIImage imageNamed:@"pushup"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = cell.frame;
    frame.origin.x = 50;
    cell.frame = frame;
    cell.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = cell.frame;
        frame.origin.x = 0;
        cell.frame = frame;
        cell.alpha = 1.0f;
    }];
    
}

@end
