//
//  TFAppDelegate.h
//  FBLoginDemo
//
//  Created by Gavin Benedict on 4/23/14.
//  Copyright (c) 2014 TeamFit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface TFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSClient *client;
@end
