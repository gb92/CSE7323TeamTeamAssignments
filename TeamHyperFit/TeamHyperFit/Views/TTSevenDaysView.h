//
//  TTSevenDaysView.h
//  TeamHyperFit
//
//  Created by Mark Wang on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TTSevenDaysView : UIView

@property (strong, nonatomic) UIColor* barColor;
@property (strong, nonatomic) NSString* text;

-(void)setStepValue:(float)value;
-(void)setMaxValue:(float)value;

@end