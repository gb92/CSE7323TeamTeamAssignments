//
//  TTStatusViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTStatusViewController.h"
#import "TTGraphView.h"
#import "TTActionTableViewCell.h"
#import "TTCaptureScreenShot.h"
#import "TTInfoViewController.h"

@interface TTStatusViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UITableView *actionTableView;
@property (weak, nonatomic) IBOutlet TTGraphView *fitpointGraphView;

@end

@implementation TTStatusViewController

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
    
    //! Fake Data for now.
    self.fitpointGraphView.data = [[NSArray alloc] initWithObjects:@(1),@(5),@(2),@(4),@(6),@(5),@(3),@(0),@(10),@(6),@(7),@(5), nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Sage
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if( [segue.identifier isEqualToString:@"info"] )
//    {
//        TTInfoViewController* destVC = (TTInfoViewController*)segue.destinationViewController;
//        UIImage* image = [TTCaptureScreenShot screenshot];
//        destVC.backgroundImage.image = [image copy];
//    }
//}

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


@end
