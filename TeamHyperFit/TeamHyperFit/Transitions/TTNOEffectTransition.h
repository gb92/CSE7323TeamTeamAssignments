//
//  TTNOEffectTransition.h
//  TeamHyperFit
//
//  Created by Mark Wang on 5/1/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

enum AnimationType
{
    AnimationTypePresent,
    AnimationTypeDismiss
};

@interface TTNOEffectTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) enum      AnimationType type;
@property (nonatomic, strong)   NSNumber* duration;

@end
