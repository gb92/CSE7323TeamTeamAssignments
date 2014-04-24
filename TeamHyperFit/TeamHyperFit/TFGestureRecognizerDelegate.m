//
//  TFGestureRecognizerDelegate.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TFGestureRecognizerDelegate.h"
#import "TFGesture.h"

@protocol TFGestureRecognizerDelegate

-(void) gestureRecognized:(TFGesture *) recognizedGesture;

@end
