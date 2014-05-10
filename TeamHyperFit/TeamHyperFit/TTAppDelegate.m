//
//  TTAppDelegate.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TFGesture.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation TTAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.userInforHandler = [TTUserInfoHandler new];
    
    NSDictionary *appDictionary=[[NSBundle mainBundle] infoDictionary];
    NSString *serverURL=[appDictionary valueForKey:@"TeamFitServerURL"];
    NSNumber *serverPort=[appDictionary valueForKey:@"TeamFitServerPort"];
    
    self.webServiceManager = [[TTWebServiceManager alloc] initWithURL:serverURL port:serverPort];
    
    self.msClient=[MSClient clientWithApplicationURLString:@"https://teamfit.azure-mobile.net/" applicationKey:@"qfHPkCDfjbGcpfzkLUYbDtmOiCugGZ68"];
    
    [FBSettings setLoggingBehavior:[NSSet setWithObject:FBLoggingBehaviorInformational]];

    [FBLoginView class];
    [FBProfilePictureView class];
    
    //!------------------------------------------------------------------------------------------
    //! Pull Gestures from sever if avaliable.
    //! Fake Data for now.
#pragma waning - This is still Fake Data.
    
    self.gestures = [[NSArray alloc] initWithObjects:
                     [[TFGesture alloc] initWithName:@"PushUp"   imageName:@"pushupBigIcon"],
                     [[TFGesture alloc] initWithName:@"SitUp"    imageName:@"situpBigIcon"],
                     [[TFGesture alloc] initWithName:@"JumpingJack" imageName:@"jumpingJackBigIcon"],
                     [[TFGesture alloc] initWithName:@"Cruches"  imageName:@"cranchingBigIcon"],
                     nil];
    
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
