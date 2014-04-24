//
//  TFGestureRecognizer.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFGestureRecognizer : NSObject

@property (nonatomic, assign)id delegate;

-(void) startGestureCapture;
-(void) stopGestureCapture;

@end
