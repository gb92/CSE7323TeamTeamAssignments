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
#import "TTAppDelegate.h"

#import "TTPositionToBoundsDynamicItem.h"

#import "TTActivitySelectionTableViewController.h"
#import "TTActivitySelectionContainerViewController.h"
#import "TTCongratulationViewController.h"

#import "TTFacebookHandler.h"

@interface TTMainViewController () <TMSetIndicaterViewDelegate, TTSevenDaysViewDelegate>

@property (strong, nonatomic) TFUserModel *userModel;

@property (weak, nonatomic) IBOutlet TTSevenDaysView *sunView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *monView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *tueView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *wesView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *thuView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *friView;
@property (weak, nonatomic) IBOutlet TTSevenDaysView *satView;

@property (weak, nonatomic) IBOutlet TMStepIndicaterView *fitpointView;

@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *calorieLabel;

@property (nonatomic) BOOL isStepHiden;

@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation TTMainViewController

-(TFUserModel*)userModel
{
    if (!_userModel) {
        _userModel = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userModel;
    }
    
    return _userModel;
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
    
}

-(void)viewDidLayoutSubviews
{

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

#pragma mark -

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
    
    self.isStepHiden = NO;
    
    [self playJellyEffect: (UIView<ResizableDynamicItem>*)self.fitpointView force:50.0f frequency:3.0 damping:0.3];
    
    //[self setupMotionEffect];
}

-(void)startActivitySession
{
    UINavigationController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityTable"];
        
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)updateInfo
{
    [self.userModel updateUserInfo:^(NSError *error)
    {
        if( !error )
        {
            NSDictionary* fitpointsThisWeek = [self.userModel.userStatistics objectForKey:@"fitpointsThisWeek"];
            int goalThisWeek = (int)[[self.userModel.userStatistics objectForKey:@"goalThisWeek"] integerValue];
            
            self.sunView.value = [[fitpointsThisWeek objectForKey:@"Sunday"]     integerValue];
            self.monView.value = [[fitpointsThisWeek objectForKey:@"Monday"]     integerValue];
            self.tueView.value = [[fitpointsThisWeek objectForKey:@"Tuesday"]    integerValue];
            self.wesView.value = [[fitpointsThisWeek objectForKey:@"Wednesday"]  integerValue];
            self.thuView.value = [[fitpointsThisWeek objectForKey:@"Thursday"]   integerValue];
            self.friView.value = [[fitpointsThisWeek objectForKey:@"Friday"]     integerValue];
            self.satView.value = [[fitpointsThisWeek objectForKey:@"Saturday"]   integerValue];
            
            self.sunView.maxValue = goalThisWeek;
            self.monView.maxValue = goalThisWeek;
            self.tueView.maxValue = goalThisWeek;
            self.wesView.maxValue = goalThisWeek;
            self.thuView.maxValue = goalThisWeek;
            self.friView.maxValue = goalThisWeek;
            self.satView.maxValue = goalThisWeek;
            
            self.fitpointView.value = (int)[self.userModel.fitPoints integerValue];
            self.fitpointView.maxValue = goalThisWeek;
            
            //! Update UI
            [self.fitpointView setNeedsDisplay];
            [self.sunView setNeedsDisplay];
        }
    }];

}


#pragma mark -
#pragma mark UIDynamic

-(void)setStepHiden:(BOOL)hidden
{
    if (hidden)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.stepsLabel.alpha = 0.0f;
            self.calorieLabel.alpha = 0.0f;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.stepsLabel.alpha = 1.0f;
            self.calorieLabel.alpha = 1.0f;
        }];
    }
}

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
    
//    
//    TTCongratulationViewController* vc = (TTCongratulationViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"CongratsView"];
//    [self presentViewController:vc animated:YES completion:nil];
//    
    [self startActivitySession];
}

#pragma mark -
#pragma mark TTSevenDayViewDelegate

-(void)TTSevenDaysViewOnPressed:(TTSevenDaysView *)view
{
    [self playJellyEffect:(UIView<ResizableDynamicItem>*)view force:0.2 frequency:3.0 damping:0.2];
}

@end
