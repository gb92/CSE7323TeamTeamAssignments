//
//  TMStepIndicaterView.h
//  TeamFit
//
//  Created by Mark Wang on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTTimeCounterView : UIView

@property (strong, nonatomic) UIColor* barColor;

@property (nonatomic) NSInteger timeSeconds;
@property (nonatomic,readonly) BOOL isStarted;

-(void)pause;
-(void)start;
-(void)reset;


@end
