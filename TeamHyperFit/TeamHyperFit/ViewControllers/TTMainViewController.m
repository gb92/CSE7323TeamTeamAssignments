//
//  TTMainViewController.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTMainViewController.h"
#import "TTSevenDaysView.h"
#import "TMStepCountViewController.h"

#import "TTPositionToBoundsDynamicItem.h"

@interface TTMainViewController () <TMSetIndicaterViewDelegate, TTSevenDaysViewDelegate>

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

@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation TTMainViewController

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
    
    self.sunView.text = @"S";
    self.monView.text = @"M";
    self.tueView.text = @"T";
    self.wesView.text = @"W";
    self.thuView.text = @"Th";
    self.friView.text = @"F";
    self.satView.text = @"Sa";
    
    self.sunView.value= 60;
    self.monView.value= 55;
    self.tueView.value= 89;
    self.wesView.value= 20;
    self.thuView.value= 0;
    self.friView.value= 10;
    self.satView.value= 35;
    
    self.sunView.delegate = self;
    self.monView.delegate = self;
    self.tueView.delegate = self;
    self.wesView.delegate = self;
    self.thuView.delegate = self;
    self.friView.delegate = self;
    self.satView.delegate = self;
    
    self.fitpointView.value = 4497;
    self.fitpointView.maxValue = 5000;
    
    self.fitpointView.barColor = [UIColor colorWithRed:(178.0f/255.0f) green:(218.0f/255.0f) blue:(89.0f/255.0f) alpha:1];
    
    self.fitpointView.delegate = self;
    [self playYoyoEffect: (UIView<ResizableDynamicItem>*)self.fitpointView force:30.0f frequency:3.0 damping:0.3];
    
    //[self setupMotionEffect];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (IBAction)onStatPressed:(id)sender
{
    [self.delegate TTMainViewControllerOnStatButtonPressed:self];
}
- (IBAction)onFriendsPressed:(id)sender
{
    [self.delegate TTMainViewControllerOnFriendsButtonPressed:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(void)playYoyoEffect:(UIView<ResizableDynamicItem>*) targetView force:(float) force frequency:(float) frequency damping:(float) damping
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
    
}

-(void)TMSetIndicaterViewPressed:(TMStepIndicaterView *)view
{
    [self playYoyoEffect:(UIView<ResizableDynamicItem>*)view force:25.0f frequency:3.0 damping:0.3];
}

#pragma mark -
#pragma mark TTSevenDayViewDelegate

-(void)TTSevenDaysViewOnPressed:(TTSevenDaysView *)view
{
    [self playYoyoEffect:(UIView<ResizableDynamicItem>*)view force:0.2 frequency:3.0 damping:0.2];
}

@end
