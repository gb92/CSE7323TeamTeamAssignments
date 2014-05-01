//
//  TTNOEffectTransition.m
//  TeamHyperFit
//
//  Created by Mark Wang on 5/1/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTNOEffectTransition.h"

@implementation TTNOEffectTransition

-(id)init
{
    self = [super init];
    if(self)
    {
        self.duration = @(0.5);
    }
    
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [self.duration floatValue];
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    if (self.type == AnimationTypePresent)
    {
        toViewController.view.layer.opacity = 0.0f;
        [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^
        {
            toViewController.view.layer.opacity = 1.0f;
            
        } completion:^(BOOL finished)
        {
            [transitionContext completeTransition:YES];
        }];
    
    }
    else if (self.type == AnimationTypeDismiss)
    {
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^
        {
            
            fromViewController.view.layer.opacity = 0.0f;
            
        } completion:^(BOOL finished)
        {
            
            [transitionContext completeTransition:YES];
            
        }];
    }
    
    
}


@end
