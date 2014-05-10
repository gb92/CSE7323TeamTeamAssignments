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


@property (strong ,nonatomic) TTSoundEffect *preparingSound;
@property (strong, nonatomic) TTSoundEffect *startSound;

@property (nonatomic) SessionState sessionState;

- (IBAction)closeButton:(UIButton *)sender;

@property (strong, nonatomic) TTHeartRateCounter *hearRateCounter;

@property (strong, nonatomic) TFGestureRecognizer *gestureRecognizer;

@property (nonatomic) int numberOfCorrectGesture;

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
    //[self.hearRateCounter start];
    
    //[self performSelector:@selector(stopHearRate) withObject:nil afterDelay:10];
    
    [self.gestureRecognizer stopGestureCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        [self.gestureRecognizer stopGestureCapture];
        
        
        
        //! Open session summery vc.
        TTSessionSummaryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionSummary"];
        
        vc.activityName = self.activityName;
        vc.activityImageName = self.activityImageName;
        
        vc.log = [self.gestureRecognizer printGestureResult];
        
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    
        
    }
    else if( self.sessionState == SS_PREPARE)
    {
        NSLog(@"Going to Start!, Reset values");
        self.numberOfCorrectGesture = 0;
        
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
        
        [self.gestureRecognizer startGestureCapture];
    }
}

-(void)TTTimeCounterDidStoped:(TTTimeCounterView *)view
{
    if( self.sessionState == SS_IN_SESSION )
    {
        self.sessionState = SS_PAUSE;
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
