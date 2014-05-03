//
//  TMStepCountViewController.m
//  TeamFit
//
//  Created by Chatchai Wangwiwiwattana on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import "TMStepCountViewController.h"
#import "TMStepIndicaterView.h"
#import "TMStatViewController.h"

#import <CoreMotion/CoreMotion.h>

static unsigned int DEFAULT_GOAL_STEPS = 4000;

@interface TMStepCountViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currentStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalStepLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;

@property (weak, nonatomic) IBOutlet TMStepIndicaterView *stepIndicaterView;


@property (nonatomic) SIActivityType activityType;
- (IBAction)onButtonTestActivityPressed:(id)sender;

// Motion Attribute section //

@property (strong,nonatomic) CMMotionActivityManager *cmActivityManager;
@property (strong,nonatomic) CMStepCounter *cmStepCounter;

@property (nonatomic) NSInteger numberOfSteps;
@property (nonatomic) NSInteger numberOfStepsSinceMorningUntilOpenApp;
@property (nonatomic) NSInteger numberOfYesterdaySteps;


@property ( strong, nonatomic ) NSUserDefaults* userDefault;

@end

@implementation TMStepCountViewController
{
    unsigned int numberOfGoalSteps;
}

-(NSUserDefaults *)userDefault
{
    if(!_userDefault)
    {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    
    return _userDefault;
}

-(CMMotionActivityManager*)cmActivityManager{
    if(!_cmActivityManager){
        if([CMMotionActivityManager isActivityAvailable])
            _cmActivityManager = [[CMMotionActivityManager alloc]init];
    }
    return _cmActivityManager;
}

-(CMStepCounter*)cmStepCounter{
    if(!_cmStepCounter){
        if([CMStepCounter isStepCountingAvailable]){
            _cmStepCounter = [[CMStepCounter alloc] init];
        }
    }
    return _cmStepCounter;
}

/*-----------------------------------*/

-(void)initActivityMotion
{
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags= NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:now];
    
    long timeToRemove=-1*([components hour]*60*60 + [components minute]*60 + [components second]);
    NSLog(@"timeToRemove: %ld", timeToRemove);
    NSDate *today = [NSDate dateWithTimeInterval:timeToRemove sinceDate:now];
    NSDate *yesterday = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:today];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-YYYY hh:mm:ss"];
    NSLog(@"NSDate today: %@",[formatter stringFromDate:today]);
    NSLog(@"NSDate yesterday: %@", [formatter stringFromDate:yesterday]);
    NSLog(@"NSDate now: %@", [formatter stringFromDate:now]);
    
    [self.cmStepCounter queryStepCountStartingFrom:yesterday to:today toQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           self.numberOfYesterdaySteps = numberOfSteps;
                                           
                                       }];
    
    
    [self.cmStepCounter queryStepCountStartingFrom:today to:now toQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                           
                                           self.numberOfStepsSinceMorningUntilOpenApp = numberOfSteps;
                                           self.numberOfSteps = numberOfSteps;
                                           
                                           [self updateUI];
                                       }];
    
    
    
    [self.cmStepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                               updateOn:1
                                            withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
                                                if(!error){
                                                    
                                                    self.numberOfSteps = self.numberOfStepsSinceMorningUntilOpenApp + numberOfSteps;
                                                    [self updateUI];
                                                }
                                            }];
    
    [self.cmActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMMotionActivity *activity) {
                                                if(activity.running){
                                                    [self setActivityType:SI_ACTIVITY_RUNNING];
                                                }else if (activity.walking){
                                                    [self setActivityType:SI_ACTIVITY_WALKING];
                                                }else if (activity.automotive){
                                                    [self setActivityType:SI_ACTIVITY_DRIVING];
                                                }else if (activity.stationary){
                                                    [self setActivityType:SI_ACTIVITY_STILL];
                                                }
                                            }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self setUpViewForOrientation:interfaceOrientation];

    self.numberOfSteps = 0;
    numberOfGoalSteps = (unsigned int)[self.userDefault integerForKey:@"numberOfGoalSteps"];
    
    if( numberOfGoalSteps <= 0 )
    {
        numberOfGoalSteps = DEFAULT_GOAL_STEPS;
    }
    
    [self initActivityMotion];
    
    [self updateUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self updateUI];
    [self setActivityType:SI_ACTIVITY_STILL];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setUpViewForOrientation:toInterfaceOrientation];
}

/*-----------------------------------------------------------------------------*/

-(void)setUpViewForOrientation:(UIInterfaceOrientation)orientation
{
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        //NSLog(@"lanscape");
        
    }
    else
    {
        //NSLog(@"pro");
    }
    
    [self.stepIndicaterView setNeedsDisplay];
}

/*-----------------------------------------------------------------------------*/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toStatView"])
    {
        TMStatViewController *statView = segue.destinationViewController;
        [statView setCurrentStep:(int)self.numberOfSteps];
        [statView setYesterdayStep:(int)self.numberOfYesterdaySteps];
    }
    else if( [segue.identifier isEqualToString:@"toSetGoalView"])
    {
        TMSetGoalStepViewController *setGoalView = segue.destinationViewController;
        //[setGoalView setCurrentGoal:[NSNumber numberWithInt:goalStep]];

        setGoalView.currentGoal = numberOfGoalSteps;
        setGoalView.delegate = self;

    }
}

/*----------------------------------------------------------------------------*/

-(void)SetGoalSetpViewControllerDidSet:(TMSetGoalStepViewController *)controller newGoal:(unsigned int)newGoal
{
    numberOfGoalSteps = newGoal;
    [self.userDefault setInteger:newGoal forKey:@"numberOfGoalSteps"];
    
    [UIView transitionWithView:self.goalStepLabel duration:1.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.goalStepLabel.textColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.0 alpha:1.0];
    } completion:^(BOOL finished) {
        [UIView transitionWithView:self.goalStepLabel duration:1.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.goalStepLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.5 alpha:1.0];
        } completion:nil];
    }];
    
    [self updateUI];
}

-(void)SetGoalSetpViewControllerDidCancel:(TMSetGoalStepViewController *)controller
{
    // Do nothing.
}

/*----------------------------------------------------------------------------*/
-(void)updateUI
{
    if( self.numberOfSteps >= numberOfGoalSteps )
    {
        
//        [UIView transitionWithView:self.currentStepLabel duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//            [self.currentStepLabel setText:@"CONGRATULATIONS!"];
//            self.currentStepLabel.font = [UIFont boldSystemFontOfSize:20];
//        } completion:^(BOOL finished) {
//
//        }];

        self.stepIndicaterView.barColor = [UIColor redColor];
    }
    else
    {
        self.stepIndicaterView.barColor = [UIColor grayColor];
    }
    
    [self.currentStepLabel setText:[NSString stringWithFormat:@"%d",(int)self.numberOfSteps]];
    [self.goalStepLabel setText:[NSString stringWithFormat:@"%d",numberOfGoalSteps]];
    
    // Make sure you set max before set current value!
//    [self.stepIndicaterView setMaxValue:numberOfGoalSteps];
//    [self.stepIndicaterView setStepValue:self.numberOfSteps];
    
}

/*----------------------------------------------------------------------------*/

-(void)TMSetIndicaterViewReachGoal:(TMStepIndicaterView *)view
{
    // Do nothing right now.
}

-(void)setActivityType:(SIActivityType)activityType
{
    //@TODO Add confidence point.
    
    NSString* imageName = [[NSString alloc] init];
    
    switch (activityType)
    {
        case SI_ACTIVITY_STILL:
            imageName = @"stand";
            break;
        case SI_ACTIVITY_RUNNING:
            imageName = @"run";
            break;
        case SI_ACTIVITY_WALKING:
            imageName = @"walkingICO";
            break;
        case SI_ACTIVITY_DRIVING:
            imageName = @"driving";
            break;
        default:
            imageName = @"stand";
            break;
    }
  
    UIImage *activityImage = [UIImage imageNamed:imageName];
    [self.activityImageView setImage:activityImage];
    
    _activityType = activityType;
}

- (IBAction)onButtonTestActivityPressed:(id)sender
{

}

@end
