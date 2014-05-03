//
//  TMStepIndicaterView.h
//  TeamFit
//
//  Created by Chatchai Wangwiwiwattana on 2/26/14.
//  Copyright (c) 2014 smu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTimeCounterView;

@protocol TTTimeCounterDelegate <NSObject>

-(void)TTTimeCounterDidStarted:(TTTimeCounterView*) view;
-(void)TTTimeCounterDidStoped:(TTTimeCounterView*) view;
-(void)TTTimeCounterDidFinshed:(TTTimeCounterView*) view;

@end


@interface TTTimeCounterView : UIView

@property (weak,nonatomic) id<TTTimeCounterDelegate> delegate;

@property (strong, nonatomic) UIColor* barColor;

@property (nonatomic) NSInteger timeSeconds;
@property (nonatomic,readonly) BOOL isStarted;

-(void)stop;
-(void)start;
-(void)reset;


@end
