//
//  TTMainViewController.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTMainViewController.h"
#import "TTSevenDaysView.h"
#import "TMStepCountViewController.h"
#import "TFUserModel.h"
#import "TTUserInfoHandler.h"
#import "TTAppDelegate.h"

#import "TTPositionToBoundsDynamicItem.h"

#import "TTActivitySelectionTableViewController.h"
#import "TTActivitySelectionContainerViewController.h"
#import "TTCongratulationViewController.h"

#import "TTFacebookHandler.h"

#import "UIScrollView+GifPullToRefresh.h"

@interface TTMainViewController () <TMSetIndicaterViewDelegate, TTSevenDaysViewDelegate>

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *sunView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *monView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *tueView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *wesView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *thuView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *friView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *satView;
@property (weak, nonatomic) IBOutlet TMStepIndicaterView *fitpointView;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;


@property (nonatomic) BOOL didMeetTodayGoal;

@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation TTMainViewController

-(TTUserInfoHandler *)userInfoHandler
{
    if (!_userInfoHandler) {
        _userInfoHandler = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userInforHandler;
    }
    
    return _userInfoHandler;
}

#pragma mark -
#pragma mark ViewController Life Cycle.

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
    
    [self setupUI];
    
    [self.userInfoHandler.userInfo addObserver:self forKeyPath:@"todaySteps" options:NSKeyValueObservingOptionNew context:nil];
    
//-------------------------------------------------------------------------------
    NSDate* now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
    
    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDate *dateMeetGoal = [defaults objectForKey:@"dateMeetGoal"];
    
#warning Bug Compare Date Alwasy get different date!.
    
    if( ([dateMeetGoal compare:today] != NSOrderedSame) )
    {
        self.didMeetTodayGoal = NO;
    }
    else
    {
        self.didMeetTodayGoal = YES;
    }
}

-(void)viewDidLayoutSubviews
{

}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateInfo];
    [self checkMeetGoal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Event Handling.

- (IBAction)onStatPressed:(id)sender
{
    [self.delegate TTMainViewControllerOnStatButtonPressed:self];
}
- (IBAction)onFriendsPressed:(id)sender
{
    [self.delegate TTMainViewControllerOnFriendsButtonPressed:self];
}
- (IBAction)testButton:(id)sender
{
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    
    [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"dateMeetGoal"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.didMeetTodayGoal = YES;
    
    //! Open Congratuations View controller only one time a day!
    //!
    TTCongratulationViewController* vc = (TTCongratulationViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"CongratsView"];
    vc.fitPoints = [self.userInfoHandler.userInfo.fitPoints integerValue];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:@"todaySteps"])
    {
        self.stepsLabel.text = [NSString stringWithFormat:@"%d", [self.userInfoHandler.userInfo.todaySteps intValue] ];
        
        self.fitpointView.value = (int)([self.userInfoHandler.userInfo.fitPoints integerValue] + [self.userInfoHandler.userInfo.todaySteps integerValue]);
        [self checkMeetGoal];
    }
}


#pragma mark -

-(void)checkMeetGoal
{
    
    if ( self.didMeetTodayGoal )
    {
        return;
    }
    
    if( ([self.userInfoHandler.userInfo.fitPoints integerValue] + [self.userInfoHandler.userInfo.todaySteps integerValue]) > [self.userInfoHandler.userInfo.goalFitPoints integerValue] )
    {
        
        NSDate* now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *components = [calendar components:unitFlags fromDate:now];
        long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
        NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
        
        [[NSUserDefaults standardUserDefaults] setObject:today forKey:@"dateMeetGoal"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.didMeetTodayGoal = YES;
        
        //! Open Congratuations View controller only one time a day!
        //!
        TTCongratulationViewController* vc = (TTCongratulationViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"CongratsView"];
        vc.fitPoints = [self.userInfoHandler.userInfo.fitPoints integerValue];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

-(void)setupUI
{
    self.sunView.text = @"S";
    self.monView.text = @"M";
    self.tueView.text = @"T";
    self.wesView.text = @"W";
    self.thuView.text = @"Th";
    self.friView.text = @"F";
    self.satView.text = @"Sa";
    
    self.sunView.delegate = self;
    self.monView.delegate = self;
    self.tueView.delegate = self;
    self.wesView.delegate = self;
    self.thuView.delegate = self;
    self.friView.delegate = self;
    self.satView.delegate = self;
    
    self.fitpointView.barColor = [UIColor colorWithRed:(178.0f/255.0f) green:(218.0f/255.0f) blue:(89.0f/255.0f) alpha:1];
    
    self.fitpointView.delegate = self;

    
    [self playJellyEffect: (UIView<ResizableDynamicItem>*)self.fitpointView force:50.0f frequency:3.0 damping:0.3];
    
    [self setupPullToRefresh];
    
    
    //[self setupMotionEffect];
}

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

        [self.userInfoHandler updateUserInfo:^(TFUserModel* userInfo, NSError *error)
        {
            if( !error )
            {
                [self updateInfo];
                [self.containerScrollView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:0];
            }
        }];
        
        [self.containerScrollView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:3];
        
    }];
    
    self.containerScrollView.alwaysBounceVertical = YES;

}

-(void)startActivitySession
{
    UINavigationController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityTable"];
        
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)updateInfo
{
    NSDictionary* fitpointsThisWeek = [self.userInfoHandler.userInfo.userStatistics objectForKey:@"fitpointsThisWeek"];
    int goalThisWeek = [self.userInfoHandler.userInfo.goalFitPoints intValue];
    
    self.sunView.value = [[fitpointsThisWeek objectForKey:@"Sunday"]     integerValue];
    self.monView.value = [[fitpointsThisWeek objectForKey:@"Monday"]     integerValue];
    self.tueView.value = [[fitpointsThisWeek objectForKey:@"Tuesday"]    integerValue];
    self.wesView.value = [[fitpointsThisWeek objectForKey:@"Wednesday"]  integerValue];
    self.thuView.value = [[fitpointsThisWeek objectForKey:@"Thursday"]   integerValue];
    self.friView.value = [[fitpointsThisWeek objectForKey:@"Friday"]     integerValue];
    self.satView.value = [[fitpointsThisWeek objectForKey:@"Saturday"]   integerValue];
    
    [self.sunView setNeedsDisplay];
    [self.monView setNeedsDisplay];
    [self.tueView setNeedsDisplay];
    [self.wesView setNeedsDisplay];
    [self.thuView setNeedsDisplay];
    [self.friView setNeedsDisplay];
    [self.satView setNeedsDisplay];
    
    self.sunView.maxValue = goalThisWeek;
    self.monView.maxValue = goalThisWeek;
    self.tueView.maxValue = goalThisWeek;
    self.wesView.maxValue = goalThisWeek;
    self.thuView.maxValue = goalThisWeek;
    self.friView.maxValue = goalThisWeek;
    self.satView.maxValue = goalThisWeek;
    
    self.fitpointView.value = (int)([self.userInfoHandler.userInfo.fitPoints integerValue] + [self.userInfoHandler.userInfo.todaySteps integerValue]);
    self.fitpointView.maxValue = goalThisWeek;
    
    //! Update UI
    [self.fitpointView setNeedsDisplay];
    

    [self.containerScrollView performSelector:@selector(didFinishPullToRefresh) withObject:nil afterDelay:1];

    self.stepsLabel.text = [NSString stringWithFormat:@"%d", [self.userInfoHandler.userInfo.todaySteps intValue] ];
    
    [self checkMeetGoal];

}


#pragma mark -
#pragma mark UIDynamic

-(void)setupMotionEffect
{
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [self.fitpointView addMotionEffect:group];
}


-(void)playJellyEffect:(UIView<ResizableDynamicItem>*) targetView force:(float) force frequency:(float) frequency damping:(float) damping
{
    targetView.bounds = targetView.defaultBounds;

    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    TTPositionToBoundsDynamicItem *boundDynamicItem = [[TTPositionToBoundsDynamicItem alloc] initWithTarget:targetView];
    
    // Create an attachment between the buttonBoundsDynamicItem and the initial
    // value of the button's bounds.
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:boundDynamicItem attachedToAnchor:boundDynamicItem.center];
    [attachmentBehavior setFrequency:frequency];
    [attachmentBehavior setDamping:damping];
    [animator addBehavior:attachmentBehavior];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[boundDynamicItem] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = M_PI_4;
    pushBehavior.magnitude = force;
    [animator addBehavior:pushBehavior];
    
    [pushBehavior setActive:TRUE];
    
    self.animator = animator;
}


#pragma mark -
#pragma mark TMSetIndicaterViewDelegate

-(void)TMSetIndicaterViewReachGoal:(TMStepIndicaterView *)view
{
    TTCongratulationViewController* vc = (TTCongratulationViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"CongratsView"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)TMSetIndicaterViewPressed:(TMStepIndicaterView *)view
{
    [self playJellyEffect:(UIView<ResizableDynamicItem>*)view force:25.0f frequency:3.0 damping:0.3];
    
    [self startActivitySession];
    
}

#pragma mark -
#pragma mark TTSevenDayViewDelegate

-(void)TTSevenDaysViewOnPressed:(TTSevenDaysView *)view
{
    [self playJellyEffect:(UIView<ResizableDynamicItem>*)view force:0.2 frequency:3.0 damping:0.2];
}

@end
