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

@optional
-(void)TTTimeCounterWillStart:(TTTimeCounterView*) sender;
-(void)TTTimeCounterDidStarted:(TTTimeCounterView*) sender;

-(void)TTTimeCounterWillStop:(TTTimeCounterView *)sender;
-(void)TTTimeCounterDidStoped:(TTTimeCounterView*) sender;

-(void)TTTimeCounterDidFinshed:(TTTimeCounterView*) sender;

-(void)TTTimeCounterWillUpdate:(TTTimeCounterView*) sender;
-(void)TTTimeCounterDidUpdate:(TTTimeCounterView*) sender;

@end


@interface TTTimeCounterView : UIView

@property (weak,nonatomic) id<TTTimeCounterDelegate> delegate;

@property (strong, nonatomic) UIColor* barColor;

@property (nonatomic, readonly) NSInteger timeSeconds;
@property (nonatomic, readonly) BOOL isStarted;

@property (nonatomic ) BOOL isDrawGate;

-(void)stop;
-(void)start;
-(void)resume;
-(void)reset;

-(void)setTimeSeconds:(NSInteger)timeSeconds;

@end
