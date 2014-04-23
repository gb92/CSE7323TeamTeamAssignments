//
//  TTAppDelegate.h
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTWebServiceManager.h"

@interface TTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TTWebServiceManager* webServiceManager;

@end