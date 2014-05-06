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

@interface TTSessionViewController ()<UIGestureRecognizerDelegate,TTTimeCounterDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeBigButton;

@property (weak, nonatomic) IBOutlet UILabel *postLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet TTTimeCounterView *timeCounterView;

- (IBAction)closeButton:(UIButton *)sender;

@property (strong, nonatomic) TTHeartRateCounter* hearRateCounter;

@end

@implementation TTSessionViewController


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
    
    self.closeBigButton.hidden = YES;
    
}


-(void)singleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (!self.timeCounterView.isStarted)
    {
        [self.timeCounterView start];
        [self hideCloseBigButton];
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

-(void)stopHearRate
{
    [self.hearRateCounter stop];
    NSLog(@"My heartRate is : %@", [self.hearRateCounter getHeartRate]);
}


#pragma mark -- TTTimerViewDelegation

-(void)TTTimeCounterDidFinshed:(TTTimeCounterView *)view
{
    NSLog(@"This Session is done.");
    [self showCloseBigButton];
}
-(void)TTTimeCounterDidStarted:(TTTimeCounterView *)view
{
    NSLog(@"This Session is started.");
}
-(void)TTTimeCounterDidStoped:(TTTimeCounterView *)view
{
    NSLog(@"This Session is stop by user.");
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
