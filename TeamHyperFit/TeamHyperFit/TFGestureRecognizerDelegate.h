//
//  TFGestureRecognizerDelegate.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFGesture.h"

@protocol TFGestureRecognizerDelegate

-(void) gestureRecognized:(TFGesture *) recognizedGesture;

@end