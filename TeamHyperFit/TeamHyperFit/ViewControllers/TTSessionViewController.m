//
//  TTSessionViewController.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSessionViewController.h"
#import "TTSessionSummaryViewController.h"
#import "TTHeartRateCounter.h"
#import "TTTimeCounterView.h"
#import "TTSoundEffect.h"
#import "TFGestureRecognizer.h"
#import "TTUserInfoHandler.h"
#import "TTAppDelegate.h"

typedef enum
{
    SS_REST,
    SS_PREPARE,
    SS_IN_SESSION,
    SS_PAUSE
    
} SessionState;

@interface TTSessionViewController ()<UIGestureRecognizerDelegate,TTTimeCounterDelegate, TTSessionSummaryViewControllerDelegate, TFGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet TTTimeCounterView *timeCounterView;
@property (weak, nonatomic) IBOutlet UILabel *modelIDLabel;

- (IBAction)closeButton:(UIButton *)sender;

@property (strong ,nonatomic) TTSoundEffect *preparingSound;
@property (strong, nonatomic) TTSoundEffect *startSound;

@property (nonatomic) SessionState sessionState;

@property (strong, nonatomic) TTUserInfoHandler *userInfoHandler;
@property (strong, nonatomic) TTHeartRateCounter *hearRateCounter;
@property (strong, nonatomic) TFGestureRecognizer *gestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel *heartRateZone;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;


@property (nonatomic) int numberOfCorrectGesture;
@property (nonatomic) BOOL isHeartRateEnable;
@property (nonatomic) NSInteger resultCount;

@end

@implementation TTSessionViewController


-(TTSoundEffect*)startSound
{
    if (!_startSound) {
        _startSound = [[TTSoundEffect alloc]initWithSoundNamed:@"beepStart.wav"];
    }
    
    return _startSound;
}

-(TTSoundEffect*)preparingSound
{
    if (!_preparingSound) {
        _preparingSound = [[TTSoundEffect alloc] initWithSoundNamed:@"beep.wav"];
    }
    
    return _preparingSound;
}

-(TTHeartRateCounter*)hearRateCounter
{
    if (!_hearRateCounter) {
        _hearRateCounter = [[TTHeartRateCounter alloc] init];
    }
    
    return _hearRateCounter;
}

-(TTUserInfoHandler*)userInfoHandler
{
    if (!_userInfoHandler) {
        _userInfoHandler = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).userInforHandler;
    }
    
    return _userInfoHandler;
}

-(TFGestureRecognizer*)gestureRecognizer
{
    if (!_gestureRecognizer) {
        _gestureRecognizer = ((TTAppDelegate*)[UIApplication sharedApplication].delegate).gestrueRecognizer;
    }
    
    return _gestureRecognizer;
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

    self.gestureRecognizer.delegate = self;
    
    [self setupUI];
    
}


-(void)singleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (!self.timeCounterView.isStarted)
    {
        if( self.sessionState == SS_REST)
        {
            [self.timeCounterView start];
        }
        else
        {
            [self.timeCounterView resume];
        }
    }
    else
    {
        [self.timeCounterView stop];
    }
}

-(void)viewDidAppear:(BOOL)animated
{

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.gestureRecognizer stopGestureCapture];
    [self.hearRateCounter stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.gestureRecognizer stopGestureCapture];
}

#pragma mark -

-(void)setupUI
{
    
    switch (self.activityType) {
        case 0: //Push up
            self.gestureRecognizer.modelDataSetID = @(41);
            NSLog(@"Use Push Up Model");
            break;
        case 1: //Sit up
            self.gestureRecognizer.modelDataSetID = @(40);
            NSLog(@"Use Set Up Model.");
            break;
        case 2: //Jumping Jack
            self.gestureRecognizer.modelDataSetID = @(40);
            NSLog(@"Use Jumping Jack Model");
            break;
        case 3: //Squrt
            self.gestureRecognizer.modelDataSetID = @(40);
            NSLog(@"Use Squart Model.");
            break;
        default:
            self.gestureRecognizer.modelDataSetID = @(41);
            NSLog(@"huh? I don't know your model?");
            break;
    }
    
    
    self.postLabel.text = self.activityName;
    self.postImageView.image = [UIImage imageNamed:self.activityImageName];
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    //    [tapGestureRecognize requireGestureRecognizerToFail:dtapGestureRecognize];
    [self.view addGestureRecognizer:tapGestureRecognize];
    
    self.timeCounterView.delegate = self;
    self.timeCounterView.isDrawGate = NO;
    
    self.sessionState = SS_REST;
    
    self.modelIDLabel.text = [NSString stringWithFormat:@"%@" ,self.gestureRecognizer.modelDataSetID];
    
    self.isHeartRateEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"heartRateEnable"];
    
}

#pragma mark -
#pragma mark Event Handling.

- (IBAction)closeButton:(UIButton *)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark -- TTSessionSummaryDelegate
-(void)TTSessionSummaryViewControllerOnCloseButtonPressed:(TTSessionSummaryViewController *)sender
{
    [sender dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- TTTimerViewDelegate

-(void)TTTimeCounterDidFinshed:(TTTimeCounterView *)view
{
    //[self showCloseBigButton];
    
    if (self.sessionState == SS_IN_SESSION)
    {
        self.sessionState = SS_REST;
        self.timeCounterView.isDrawGate = NO;
        
        NSLog(@"End Session; Change to Rest..");
        [self.startSound play];
        
        [self.hearRateCounter stop];
        [self.gestureRecognizer stopGestureCapture];
        
        //! Open session summery vc.
        TTSessionSummaryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionSummary"];
        
        vc.activityName = self.activityName;
        vc.activityImageName = self.activityImageName;
        //vc.numberRaps = [self.gestureRecognizer getRapsByActivityID: ];
        
        //! Only for testing.
#warning Please Remove This Test code.
        
        int gestureTypeCount[4];
        
        for(int i=0; i<4;i++)
        {
            gestureTypeCount[i] = 0;
        }
        
        
        gestureTypeCount[0] = (int)self.gestureRecognizer.pushUpNumber;
        gestureTypeCount[1] = (int)self.gestureRecognizer.sitUpNumber;
        gestureTypeCount[2] = (int)self.gestureRecognizer.jumpingJackNumber;
        gestureTypeCount[3] = (int)self.gestureRecognizer.squartNumber;
        
        NSString *result = @"";
        for(int i=0; i<4; i++)
        {
            NSString *gestureName;
            
            if( i == 0 )
            {
                gestureName = @"Push Up";
            }
            else if( i == 1 )
            {
                gestureName = @"Sit Up";
            }
            else if( i == 2 )
            {
                gestureName = @"Jumping Jack";
            }
            else
            {
                gestureName = @"Squat";
            }
            
            result = [NSString stringWithFormat:@"%@ \n %@ : %d", result, gestureName, gestureTypeCount[i] ];
        }
        
        vc.numberRaps = gestureTypeCount[ self.activityType ];
        
        self.userInfoHandler.userInfo.fitPoints = @( [self.userInfoHandler.userInfo.fitPoints intValue] + vc.numberRaps * 100);
        
        vc.log = result;
        NSLog(@"%@",result);
        
        
        //vc.log = [self.gestureRecognizer printGestureResult];
        //! --- End testing code.
        
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    
        
    }
    else if( self.sessionState == SS_PREPARE)
    {
        NSLog(@"Going to Start!, Reset values");
        self.numberOfCorrectGesture = 0;
        
        if (self.isHeartRateEnable)
        {
            [self.hearRateCounter start];
        }
        [self.gestureRecognizer clearGesturePredictedData];
        [self.gestureRecognizer startGestureCapture];
        
        [self.timeCounterView setTimeSeconds:30];
        self.sessionState = SS_IN_SESSION;
        
        [self.timeCounterView start];
        
        [self.startSound play];
        
    }
}

-(void)TTTimeCounterWillStart:(TTTimeCounterView *)sender
{
    self.timeCounterView.isDrawGate = YES;
    
    if( self.sessionState == SS_REST )
    {
        NSLog(@"Prepare to start; Add 3 seconds count down.");
        [self.timeCounterView setTimeSeconds:3];
        self.sessionState = SS_PREPARE;
    }
    else if( self.sessionState == SS_PAUSE)
    {
        self.sessionState = SS_IN_SESSION;
        
        //! Measure Heart rate and Gesture.
        if (self.isHeartRateEnable)
        {
            [self.hearRateCounter start];
        }
        self.resultCount = 0;
        [self.gestureRecognizer startGestureCapture];
    }
}

-(void)TTTimeCounterDidStoped:(TTTimeCounterView *)view
{
    if( self.sessionState == SS_IN_SESSION )
    {
        self.sessionState = SS_PAUSE;
        
        //! Stop measure heart rate.
        [self.hearRateCounter stop];
        [self.gestureRecognizer stopGestureCapture];
    }
}

-(void)TTTimeCounterDidUpdate:(TTTimeCounterView *)sender
{
    if (self.sessionState == SS_PREPARE)
    {
        //! Play Sound.
        NSLog(@"player sound");
        [self.preparingSound play];
    }
    else if (self.sessionState == SS_IN_SESSION )
    {
        //! Read Heart Rate.
        if([self.hearRateCounter isStated])
        {
            int age = (int)self.userInfoHandler.userInfo.age;
            int gender = 0;
            if( [self.userInfoHandler.userInfo.gender isEqualToString:@"female"])
                gender = 1;
            
            NSLog(@"heartRate : %@, %@",[self.hearRateCounter getHeartRate], [self.hearRateCounter heartRateZoneForGender:gender atAge:age]);
            
            self.heartRateLabel.text = [NSString stringWithFormat:@"%@ bpm", [self.hearRateCounter getHeartRate]];
            self.heartRateZone.text = [self.hearRateCounter heartRateZoneForGender:gender atAge:age];
        }
    }
}

-(void)TFGestureRecognizerDidDetectBegin:(TFGestureRecognizer *)sender
{
    [self.preparingSound play];
}

-(void)TFGestureRecognizerDidDetectEnd:(TFGestureRecognizer *)sender
{
    [self.startSound play];
}

@end
