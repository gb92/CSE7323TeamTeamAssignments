//
//  TTGraphView.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/25/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTGraphView;

@protocol TTGraphViewDelegate <NSObject>

-(void)TTGraphViewDidPressed:(TTGraphView*)sender;

@end

@interface TTGraphView : UIView

@property (weak, nonatomic) id<TTGraphViewDelegate> delegate;

@property (strong, nonatomic) NSArray* data;

@property (strong, nonatomic) NSNumber* numberOfColumn;

@property (nonatomic) BOOL isShowPointNumber;

@end
