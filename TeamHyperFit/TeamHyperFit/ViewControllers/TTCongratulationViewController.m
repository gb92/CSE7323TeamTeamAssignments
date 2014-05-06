//
//  TTCongratulationView.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/6/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTCongratulationViewController.h"
#import "TTCaptureScreenShot.h"
#import "TTNOEffectTransition.h"

@interface TTCongratulationViewController ()<UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIView *animatedView;

@property (nonatomic) CGRect defaultSize;
@property (nonatomic) CGRect endSize;

@end

@implementation TTCongratulationViewController

#pragma mark -
#pragma mark ViewController Life Cycle.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitioningDelegate = self;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //! Calculate frame for animation.
    
    self.defaultSize = self.animatedView.frame;

    CGRect tempRect = self.defaultSize;
    
    tempRect.origin.x += self.defaultSize.size.width / 2;
    tempRect.origin.y += self.defaultSize.size.height / 2;
    tempRect.size.width = 0;
    tempRect.size.height = 0;
    
    self.endSize = tempRect;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.image = [TTCaptureScreenShot screenshot];
    self.backgroundImage.image = self.image;
    
    self.fitpointLabel.hidden = YES;
    
    [self performSelectorInBackground:@selector(blurBG) withObject:nil ];
    
}

-(void)viewDidLayoutSubviews
{
    [self.animatedView setFrame:self.endSize];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(runNoteAnimation) withObject:nil afterDelay:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)blurBG
{
    self.image = [TTCaptureScreenShot blur:self.image];
    self.backgroundImage.image = self.image;
}

-(void)runNoteAnimation
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.animatedView.frame = self.defaultSize;
                     }
                     completion:^(BOOL Animation){
                     
                         self.fitpointLabel.hidden = NO;
                     
                     }];
}

-(void)playCloseAnimation
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.animatedView.frame = self.endSize;
                         self.fitpointLabel.alpha = 0.0f;
                     }
                     completion:^(BOOL finish){
                         
                         [self dismissViewControllerAnimated:YES completion:nil];
                         
                     }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self playCloseAnimation];
}



#pragma mark -- Custom Transition Delegation

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TTNOEffectTransition *st = [[TTNOEffectTransition alloc] init];
    st.type = AnimationTypeDismiss;
    st.duration = @(0.1);
    return st;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TTNOEffectTransition *st = [[TTNOEffectTransition alloc] init];
    st.type = AnimationTypePresent;
    st.duration = @(0.1);
    return st;
}
@end
