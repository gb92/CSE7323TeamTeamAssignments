//
//  TMStepIndicaterView.h
//  TeamFit
//
//  Created by Mark Wang on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMStepIndicaterView;

@protocol TMSetIndicaterViewDelegate <NSObject>

-(void)TMSetIndicaterViewReachGoal:(TMStepIndicaterView*) view;
-(void)TMSetIndicaterViewPressed:(TMStepIndicaterView *) view;

@end


@interface TMStepIndicaterView : UIView

@property (weak,nonatomic) id<TMSetIndicaterViewDelegate> delegate;

@property (nonatomic) CGRect defaultBounds;
@property (strong, nonatomic) UIColor* barColor;

@property(nonatomic) int value;
@property(nonatomic) int maxValue;

@end
