//
//  TTWebServiceManagerTests.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/23/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TTWebServiceManager.h"

#define AGWW_SHORTHAND
#import "AGAsyncTestHelper.h"

@interface TTWebServiceManagerTests : XCTestCase

@property (strong, nonatomic) TTWebServiceManager* webServiceManager;

@end

@implementation TTWebServiceManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.webServiceManager = [[TTWebServiceManager alloc] init];
    self.webServiceManager.serverURL = @"http://teamhyperfit.cloudapp.net";
    self.webServiceManager.serverPort = @(8000);
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testSendPostRequest
{
    
    __block BOOL jobDone = NO;
    
    [self.webServiceManager sentPost:@{@"a":@5} to:@"test" callback:^( NSData* data){
        NSString* stringOfData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Result Data : %@",stringOfData);
        
        jobDone = YES;
    }];
    
    WAIT_WHILE(!jobDone, 2.0);

}

- (void)testSendGetRequest
{
    
    __block BOOL jobDone = NO;
    
    [self.webServiceManager sentPost:@{@"a":@5} to:@"test" callback:^( NSData* data){
        NSString* stringOfData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Result Data : %@",stringOfData);
        
        jobDone = YES;
    }];
    
    WAIT_WHILE(!jobDone, 2.0);
    
}


@end
