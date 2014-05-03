//
//  TTWebServiceManager.h
//  TeamHyperFit
//
//  Created by Chatchai Wangwiwiwattana on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^webCallBackBlock)(NSData*);

@interface TTWebServiceManager : NSObject

    @property (nonatomic, strong) NSString* serverURL;
    @property (nonatomic, strong) NSNumber* serverPort;

    -(id)initWithURL:(NSString*) url port:(NSNumber*) port;

    -(void)sendPost:(NSDictionary*) data to:(NSString*) webModule callback:(webCallBackBlock) callbackBlock;
    -(void)sendGet:(NSDictionary*) data to:(NSString*) webModule callback:(webCallBackBlock) callbackBlock;

@end
