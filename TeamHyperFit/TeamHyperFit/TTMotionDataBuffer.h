//
//  TTMotionDataBuffer.h
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTMotionDataBuffer : NSObject

//TTMotionDataBufferDelegate
@property (nonatomic, assign) id delegate;

-(id) initWithBufferLength:(int) bufferLength;

-(void) addNewAccelerationData: (float) accelerationX withY:(float) accelerationY withZ:(float) accelerationZ;

-(NSArray *) getDataAsVector;


@end
