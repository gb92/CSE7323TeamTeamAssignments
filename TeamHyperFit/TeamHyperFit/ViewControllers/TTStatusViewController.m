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

#import "UIScrollView+GifPullToRefresh.h"

@interface TTStatusViewController ()<UITableViewDataSource, UITableViewDelegate, TTGraphViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;

@property (weak, nonatomic) IBOutlet UICountingLabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UICountingLabel *calorieLabel;
@property (weak, nonatomic) IBOutlet UITableView *actionTableView;
@property (weak, nonatomic) IBOutlet TTGraphView *fitpointGraphView;

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;

@end

@implementation TTStatusViewController


-(TTUserInfoHandler *)userInfoHandler
{
    if (!_userInfoHandler) {
        _userInfoHandler = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userInforHandler;
    }
    
    return _userInfoHandler;
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
    self.fitpointGraphView.numberOfColumn = @(7);
    
    self.fitpointGraphView.delegate = self;
    
    [self setupPullToRefresh];
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

-(void)setupPullToRefresh
{
    
    NSMutableArray *TwitterMusicDrawingImgs = [NSMutableArray array];
    NSMutableArray *TwitterMusicLoadingImgs = [NSMutableArray array];
    for (int i  = 0; i <= 27; i++) {
        NSString *fileName = [NSString stringWithFormat:@"sun_00%03d.png",i];
        [TwitterMusicDrawingImgs addObject:[UIImage imageNamed:fileName]];
    }
    
    for (int i  = 28; i <= 109; i++) {
        NSString *fileName = [NSString stringWithFormat:@"sun_00%03d.png",i];
        [TwitterMusicLoadingImgs addObject:[UIImage imageNamed:fileName]];
    }
    
    [self.containerScrollView addPullToRefreshWithDrawingImgs:TwitterMusicDrawingImgs andLoadingImgs:TwitterMusicLoadingImgs andActionHandler:^{
        
        [self updateInfo];
        
        [self.containerScrollView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:3];
        
    }];
    
    self.containerScrollView.alwaysBounceVertical = YES;
    
    
}

-(void)updateInfo
{
    //! Fake Data for now.
    self.fitpointGraphView.data = [[NSArray alloc] initWithObjects:@(1),@(5),@(2),@(4),@(6),@(5),@(3),@(0),@(10),@(6),@(7),@(5), nil];

    int steps = [self.userInfoHandler.userInfo.todaySteps intValue];
    self.stepsLabel.format = @"%d";
    self.stepsLabel.method = UILabelCountingMethodEaseOut;
    [self.stepsLabel countFrom:steps - 10 to:steps withDuration:0.5f];
    
    //int caluries = [self.userInfoHandler.userInfo.calories intValue];
    self.calorieLabel.format = @"%d";
    self.calorieLabel.method = UILabelCountingMethodEaseOut;
    //[self.calorieLabel countFrom:caluries-10 to:caluries withDuration:0.5f];
}

#pragma mark -
#pragma mark Table View Datasource

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

#pragma mark -
#pragma mark Table View Datasource

-(void)TTGraphViewDidPressed:(TTGraphView *)sender
{
    sender.isShowPointNumber = !sender.isShowPointNumber;
    [sender setNeedsDisplay];
}

@end
