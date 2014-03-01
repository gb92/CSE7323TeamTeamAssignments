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

@end


@interface TMStepIndicaterView : UIView

@property (weak,nonatomic) id<TMSetIndicaterViewDelegate> delegate;

-(void)setStepValue:(float)value;
-(void)setMaxValue:(float)value;

@end
