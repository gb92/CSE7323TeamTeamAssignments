//
//  TTSessionViewController.m
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTSessionViewController.h"
#import "TTHeartRateCounter.h"
#import "TTTimeCounterView.h"
#import "TTSoundEffect.h"

typedef enum
{
    SS_REST,
    SS_PREPARE,
    SS_IN_SESSION,
    SS_PAUSE
    
} SessionState;

@interface TTSessionViewController ()<UIGestureRecognizerDelegate,TTTimeCounterDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeBigButton;

@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet TTTimeCounterView *timeCounterView;


@property (strong ,nonatomic) TTSoundEffect *preparingSound;
@property (strong, nonatomic) TTSoundEffect *startSound;

@property (nonatomic) SessionState sessionState;

- (IBAction)closeButton:(UIButton *)sender;

@property (strong, nonatomic) TTHeartRateCounter* hearRateCounter;

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

    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
//    [tapGestureRecognize requireGestureRecognizerToFail:dtapGestureRecognize];
    [self.view addGestureRecognizer:tapGestureRecognize];
    
    self.timeCounterView.delegate = self;
    self.timeCounterView.isDrawGate = NO;
    
    self.closeBigButton.hidden = YES;
    
    self.sessionState = SS_REST;
}

-(void)singleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (!self.timeCounterView.isStarted)
    {
        if( self.sessionState == SS_REST)
        {
            [self.timeCounterView start];
            [self hideCloseBigButton];
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



#pragma mark -- TTTimerViewDelegation

-(void)TTTimeCounterDidFinshed:(TTTimeCounterView *)view
{
    //[self showCloseBigButton];
    
    if (self.sessionState == SS_IN_SESSION)
    {
        self.sessionState = SS_REST;
        self.timeCounterView.isDrawGate = NO;
        
        NSLog(@"End Session; Change to Rest..");
        [self.startSound play];
    }
    else if( self.sessionState == SS_PREPARE)
    {
        NSLog(@"Going to Start!, Reset values");
        
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
    }
}

-(void)TTTimeCounterDidStoped:(TTTimeCounterView *)view
{
    if( self.sessionState == SS_IN_SESSION )
    {
        self.sessionState = SS_PAUSE;
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

#pragma mark -- Controls animation

-(void)showCloseBigButton
{
    const int kOffset = 20;
    
    CGRect originalFrame = self.closeBigButton.frame;
    CGRect startFrame = originalFrame;
    startFrame.origin.y += kOffset;
    
    self.closeBigButton.hidden = NO;
    self.closeBigButton.alpha = 0.0f;
    self.closeBigButton.frame = startFrame;
    
    [UIView animateWithDuration:0.5f animations:^{
    
        self.closeBigButton.frame = originalFrame;
        self.closeBigButton.alpha = 1.0f;
        
    }];
}

-(void)hideCloseBigButton
{
    const int kOffset = 20;

    CGRect originalFrame = self.closeBigButton.frame;
    CGRect startFrame = originalFrame;
    startFrame.origin.y += kOffset;

    self.closeBigButton.alpha = 1.0f;

    [UIView animateWithDuration:0.5f animations:^{
        
        self.closeBigButton.frame = startFrame;
        self.closeBigButton.alpha = 0.0f;
        
    }];

}

@end
