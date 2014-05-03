//
//  TTSevenDaysView.h
//  TeamHyperFit
//
//  Created by Mark Wang on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTSevenDaysView;

@protocol TTSevenDaysViewDelegate <NSObject>

-(void)TTSevenDaysViewOnPressed:(TTSevenDaysView*)view;

@end

@interface TTSevenDaysView : UIView

@property (weak, nonatomic) id<TTSevenDaysViewDelegate> delegate;

@property (nonatomic) CGRect defaultBounds;

@property (strong, nonatomic) UIColor* barColor;
@property (strong, nonatomic) NSString* text;

-(void)setStepValue:(float)value;
-(void)setMaxValue:(float)value;

@end