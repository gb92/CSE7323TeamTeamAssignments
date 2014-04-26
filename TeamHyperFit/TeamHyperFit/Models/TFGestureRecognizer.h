//
//  TFGestureRecognizer.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTMotionDataBufferDelegate.h"

@interface TFGestureRecognizer : NSObject <TTMotionDataBufferDelegate>

@property (nonatomic, assign)id delegate;

-(void) startGestureCapture;
-(void) stopGestureCapture;

@end
