//
//  TTMotionDataBuffer.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTMotionDataBuffer.h"
#import "TTMotionDataBufferDelegate.h"

#define DEFAULT_BUFFER_LENGTH 20

@interface TTMotionDataBuffer()

@property (strong, nonatomic) NSMutableArray* xData;
@property (strong, nonatomic) NSMutableArray* yData;
@property (strong, nonatomic) NSMutableArray* zData;

@property int currentPos;
@property int bufferLength;

@end

@implementation TTMotionDataBuffer

-(id)init{
    self = [super init];
    if(self){
        self.currentPos = 0;
        self.bufferLength=DEFAULT_BUFFER_LENGTH;
    }
    return self;
}

-(id) initWithBufferLength:(int) bufferLength
{
    self = [super init];
    if(self){
        self.currentPos = 0;
        self.bufferLength=bufferLength;
    }
    return self;
}

-(NSMutableArray *) xData
{
    if(_xData == nil)
    {
        _xData=[[NSMutableArray alloc] initWithCapacity:self.bufferLength];
    }
    
    return _xData;
}

-(NSMutableArray *) yData
{
    if(_yData == nil)
    {
        _yData= [[NSMutableArray alloc] initWithCapacity:self.bufferLength];
    }
    
    return _yData;
}

-(NSMutableArray *) zData
{
    if(_zData == nil)
    {
        _zData= [[NSMutableArray alloc] initWithCapacity:self.bufferLength];
    }
    
    return _zData;
}

-(void) addNewAccelerationData: (float) accelerationX withY:(float) accelerationY withZ:(float) accelerationZ
{
    self.xData[self.currentPos]=@(accelerationX);
    self.yData[self.currentPos]=@(accelerationY);
    self.zData[self.currentPos]=@(accelerationZ);
    
    [self incrementCurrentPos];
}

-(void) incrementCurrentPos
{
    self.currentPos++;
    
    if(self.currentPos>self.bufferLength)
    {
        //if the current position is greater than the buffer length
        //send the vector representation of the data off to the delegate
        if(self.delegate != nil &&[self.delegate respondsToSelector:@selector(accelerationDataBufferFilled:)])
        {
            [self.delegate accelerationDataBufferFilled:[self getDataAsVector]];
        }
        
        self.xData=nil;
        self.yData=nil;
        self.zData=nil;
    }
    
    
}

-(NSArray *) getDataAsVector
{
    NSMutableArray *vec=[[NSMutableArray alloc] initWithCapacity:(3*self.bufferLength)];
    
    for(int i=0; i<self.bufferLength;i++)
    {
        vec[3*i]=self.xData[i];
        vec[(3*i)+1]=self.yData[i];
        vec[(3*i)+2]=self.zData[i];
    }
    
    return vec;
}

@end
