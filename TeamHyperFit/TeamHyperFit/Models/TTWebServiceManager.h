//
//  TTWebServiceManager.h
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^webCallBackBlock)(NSData*);

@interface TTWebServiceManager : NSObject

@property (nonatomic, strong) NSString* serverURL;
@property (nonatomic, strong) NSNumber* serverPort;

-(void)senPost:(NSDictionary*) data to:(NSString*) webModule callback:(webCallBackBlock) callbackBlock;

-(void)senGet:(NSDictionary*) data to:(NSString*) webModule callback:(webCallBackBlock) callbackBlock;

@end
