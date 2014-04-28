//
//  TTFacebookHandler.m
//  TeamHyperFit
//
//  Created by Gavin Benedict on 4/26/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTFacebookHandler.h"
#import "TTAppDelegate.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
@interface TTFacebookHandler()

@property (weak, nonatomic) MSClient *client;
@property (strong, nonatomic) NSString *fbID;
@end

@implementation TTFacebookHandler

-(MSClient *) client
{
    if(_client == nil)
    {
        TTAppDelegate *appDelegate=(TTAppDelegate *)[[UIApplication sharedApplication]delegate];
        
        _client=appDelegate.msClient;
    }
    return _client;
}

-(NSNumber *) getCurrentUserFitPoints
{
    return nil;
}

-(NSArray *) getFriendsFitPoints
{
    return nil;
}

-(void) updateCurrentUserFitPoints
{
    
}
@end
