//
//  TTWebServiceManager.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTWebServiceManager.h"

@interface TTWebServiceManager() <NSURLSessionTaskDelegate>

@property (strong,nonatomic) NSURLSession* session;

@end

@implementation TTWebServiceManager

#pragma mark - instantiation

-(NSURLSession*) session
{
    if (!_session) {
        
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        sessionConfig.timeoutIntervalForRequest = 5.0;
        sessionConfig.timeoutIntervalForResource = 8.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                 delegate:self
                                            delegateQueue:nil];
    }
    
    return _session;
}


-(id)init
{
    if ([super init])
    {
        
    }
    
    return self;
}

-(void)sentPost:(NSDictionary*) data to:(NSString*) webModule callback:(webCallBackBlock) callbackBlock
{
    assert( [data count] > 0 );
    assert( [self.serverURL length] > 0 );
    
    if (self.serverURL.length <= 0)
    {
        NSLog(@"Server URL is empty. Please set server URL before use this function.");
        return;
    }
    
    if( [data count] <= 0 ) return;

    NSString *baseURL = [NSString stringWithFormat:@"%@:%@/%@",self.serverURL, self.serverPort, webModule ];
    NSURL *postUrl = [NSURL URLWithString:baseURL];

    NSError *error = nil;
    
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         if(!error)
                                                         {
                                                             //!@TODO : Handle response;
                                                             
                                                             callbackBlock(data);
                                                         }
                                                         else
                                                         {
                                                             //!@TODO : LOG error
                                                             NSLog(@"%@", error);
                                                         }
                                                     }];
    [postTask resume];
}

-(void)sentGet:(NSDictionary*) data to:(NSString*) webModule callback:(webCallBackBlock) callbackBlock
{
    
    assert( [self.serverURL length] > 0 );
    
    if (self.serverURL.length <= 0)
    {
        NSLog(@"Server URL is empty. Please set server URL before use this function.");
        return;
    }
    
    NSMutableString *baseURL = [NSMutableString stringWithFormat:@"%@:%@/%@",self.serverURL, self.serverPort, webModule];
    
    if ( [data count] > 0 )
    {
        [baseURL appendString:@"?"];
    }
    
    for ( NSString* key in data)
    {
        [baseURL appendString: [NSString stringWithFormat:@"%@=%@&", key, [data objectForKey:key]  ] ];
    }
    
    //! Remove '&' at the end of the string.
    [baseURL substringToIndex:[baseURL length] - 2];
    
    NSURL *serviceURL = [NSURL URLWithString:baseURL];
    NSURLSessionTask *theTask = [self.session dataTaskWithURL:serviceURL
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if (!error)
                                                {
                                                    callbackBlock(data);
                                                }
                                                else
                                                {
                                                    NSLog(@"%@", error);
                                                }
                                            }];
    
    [theTask resume];
}

@end
