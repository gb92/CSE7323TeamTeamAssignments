//
//  TTAppDelegate.h
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTWebServiceManager.h"
#import "TTUserInfoHandler.h"
#import "TTA7ActivityHandler.h"

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface TTAppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TTWebServiceManager* webServiceManager;

@property (strong, nonatomic) MSClient *msClient;
@property (strong, nonatomic) NSArray *gestures;
@property (strong, nonatomic) TTUserInfoHandler *userInforHandler;


//! For Prototyping only! Please change to the real thing.
@property (nonatomic) BOOL activitySessionMode;

@end