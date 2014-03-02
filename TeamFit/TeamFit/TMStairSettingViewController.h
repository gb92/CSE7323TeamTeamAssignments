//
//  TMStairSettingViewController.h
//  TeamFit
//
//  Created by Mark Wang on 3/1/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMStairSettingViewController;

@protocol TMStairSettingViewControllerDelegate <NSObject>

-(void)TMStairSettingViewControllerSetButtonPressed:(TMStairSettingViewController*) controller withThresholdValue:(float) thresholdValue;
-(void)TMStairSettingViewControllerCancelButtonPressed:(TMStairSettingViewController*) controller;

@end


@interface TMStairSettingViewController : UIViewController

@property (strong, nonatomic) id<TMStairSettingViewControllerDelegate> delegate;

-(void)setThresholdValue:(float)value;

@end
