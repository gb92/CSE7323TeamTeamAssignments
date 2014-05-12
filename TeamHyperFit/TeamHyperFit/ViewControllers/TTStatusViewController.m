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
#import "TFGesture.h"

#import "UIScrollView+GifPullToRefresh.h"

@interface TTStatusViewController ()<UITableViewDataSource, UITableViewDelegate, TTGraphViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;

@property (weak, nonatomic) IBOutlet UICountingLabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UITableView *actionTableView;
@property (weak, nonatomic) IBOutlet TTGraphView *fitpointGraphView;

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;
@property (strong, nonatomic) NSArray* gestures;

@end

@implementation TTStatusViewController

-(NSArray*)gestures
{
    if (!_gestures) {
        _gestures = ((TTAppDelegate*)[[UIApplication sharedApplication]delegate]).gestures;
    }
    
    return _gestures;
}


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

-(NSInteger)getWeekdayFromDate:(NSDate*) date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [weekdayComponents weekday];
    
    return weekday;
}


-(void)updateInfo
{
    NSMutableArray *dateData = [[NSMutableArray alloc] init];
    [dateData addObjectsFromArray:@[@(self.userInfoHandler.userInfo.sunFitPoints),
                                    @(self.userInfoHandler.userInfo.monFitPoints),
                                    @(self.userInfoHandler.userInfo.tueFitPoints),
                                    @(self.userInfoHandler.userInfo.wenFitPoints),
                                    @(self.userInfoHandler.userInfo.thuFitPoints),
                                    @(self.userInfoHandler.userInfo.friFitPoints)]];
    
    NSMutableArray *dateDataToGraph = [[NSMutableArray alloc] init];
    
    NSInteger weekday = [self getWeekdayFromDate:[NSDate date]];
    
    for( int i=0; i<weekday; i++ )
    {
        [dateDataToGraph addObject: dateData[i]];
    }
    
    self.fitpointGraphView.data = [NSArray arrayWithArray:dateDataToGraph];

    int steps = [self.userInfoHandler.userInfo.todaySteps intValue];
    self.stepsLabel.format = @"%d";
    self.stepsLabel.method = UILabelCountingMethodEaseOut;
    [self.stepsLabel countFrom:steps - 10 to:steps withDuration:0.5f];
    
    [self.actionTableView reloadData];

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
    
    cell.actionNameLabel.text = ((TFGesture*)self.gestures[indexPath.row]).name;
    cell.numberOfRepsLabel.text = [NSString stringWithFormat:@"%d Reps",[self.userInfoHandler.userInfo.gesturesPoints[indexPath.row] intValue]];
    cell.actionImageView.image = [UIImage imageNamed:((TFGesture*)self.gestures[indexPath.row]).imageName];
    
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
