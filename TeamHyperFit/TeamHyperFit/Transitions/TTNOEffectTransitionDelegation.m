//
//  TTNOEffectTransitionDelegation.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/1/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTNOEffectTransitionDelegation.h"
#import "TTNOEffectTransition.h"

@implementation TTNOEffectTransitionDelegation

#pragma mark -- Custom Transition Delegation

-(id)init
{
    self = [super init];
    if(self)
    {
        self.duration = @(0.5);
    }
    
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TTNOEffectTransition *st = [[TTNOEffectTransition alloc] init];
    st.type = AnimationTypeDismiss;
    st.duration = self.duration;
    return st;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TTNOEffectTransition *st = [[TTNOEffectTransition alloc] init];
    st.type = AnimationTypePresent;
    st.duration = self.duration;
    return st;
}

@end
