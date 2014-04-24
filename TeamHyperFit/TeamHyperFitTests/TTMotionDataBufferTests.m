//
//  TTMotionDataBufferTests.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/24/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TTMotionDataBuffer.h"
#import "TTMotionDataBufferDelegate.h"

#define BUFFER_LENGTH 2

@interface TTMotionDataBufferTests : XCTestCase <TTMotionDataBufferDelegate>

@property (strong, nonatomic) TTMotionDataBuffer *buffer;
@property BOOL accelerationDataBufferFilledCorrectly;

@end

@implementation TTMotionDataBufferTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
 
    self.buffer=[[TTMotionDataBuffer alloc] initWithBufferLength:BUFFER_LENGTH];
    self.buffer.delegate=self;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    self.buffer=nil;
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void) testAddAccelerationData
{
    [self.buffer addNewAccelerationData:3.2f withY:2.8f withZ:1.2f];
    NSArray *vec=[self.buffer getDataAsVector];
    
    XCTAssertEqual(vec[0], @(3.2f));
    XCTAssertEqual(vec[1], @(2.8f));
    XCTAssertEqual(vec[2], @(1.2f));
}

-(void) testFillBuffer
{
    for(int i=0; i<BUFFER_LENGTH; i++)
    {
        [self.buffer addNewAccelerationData:2.2f withY:2.1f withZ:3.8f];
    }
}

-(void) accelerationDataBufferFilled:(NSArray *) accelerationVector
{
    
}
@end
