//
//  TMSetGoalStepViewController.h
//  TeamFit
//
//  Created by Mark Wang on 2/27/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMSetGoalStepViewController;

@protocol TMSetGoalStepViewControllerDelegate <NSObject>

-(void)SetGoalSetpViewControllerDidSet:(TMSetGoalStepViewController *) controller newGoal:(unsigned int)newGoal;
-(void)SetGoalSetpViewControllerDidCancel:(TMSetGoalStepViewController *) controller;

@end

@interface TMSetGoalStepViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) id<TMSetGoalStepViewControllerDelegate> delegate;

@property (nonatomic, readonly) unsigned int newStepGoal;
@property (nonatomic) unsigned int currentGoal;


@end
