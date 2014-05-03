//
//  TTAppDelegate.m
//  TeamHyperFit
//
//  Created by Mark Wang on 4/22/14.
//  Copyright (c) 2014 SMU. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TFGesture.h"

@implementation TTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *appDictionary=[[NSBundle mainBundle] infoDictionary];
    NSString *serverURL=[appDictionary valueForKey:@"TeamFitServerURL"];
    NSNumber *serverPort=[appDictionary valueForKey:@"TeamFitServerPort"];
    
    self.webServiceManager = [[TTWebServiceManager alloc] initWithURL:serverURL port:serverPort];
    
    self.msClient=[MSClient clientWithApplicationURLString:@"https://teamfit.azure-mobile.net/" applicationKey:@"qfHPkCDfjbGcpfzkLUYbDtmOiCugGZ68"];
    
    //! Pull Gestures from sever if avaliable.
    //! Fake Data for now.
#pragma waning - This is still Fake Data.
    
    self.gestures = [[NSArray alloc] initWithObjects:
                     [[TFGesture alloc] initWithName:@"PushUp"   imageName:@"pushupBigIcon"],
                     [[TFGesture alloc] initWithName:@"SitUp"    imageName:@"situpBigIcon"],
                     [[TFGesture alloc] initWithName:@"JumpingJack" imageName:@"jumpingJackBigIcon"],
                     [[TFGesture alloc] initWithName:@"Cruches"  imageName:@"cranchingBigIcon"],
                     nil];
    
    
    self.userModel = [[TFUserModel alloc] init];
    self.userModel.userID = @(123456);
    self.userModel.username = @"MARK USER NAME";
    self.userModel.firstName = @"Chatchai";
    self.userModel.lastName = @"Wangwiwattana";
    self.userModel.middleName = @"Mark";
    self.userModel.fitPoints = @(45698);
    self.userModel.goalFitPoints = @(50000);
    self.userModel.calories = @(23125);
    
    NSDictionary* fitPointsThisWeek = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @(10000),@"Sunday",
                                       @(30000),@"Monday",
                                       @(2000),@"Tuesday",
                                       @(0),@"Wednesday",
                                       @(50000),@"Thursday",
                                       @(0),@"Friday",
                                       @(0),@"Saturday",
                                       nil];
    
    NSNumber* goalThisWeek = @(50000);
    
    self.userModel.userStatistics = [NSDictionary dictionaryWithObjectsAndKeys:
                                     fitPointsThisWeek,@"fitpointsThisWeek",
                                     goalThisWeek,@"goalThisWeek", nil];
    
    return YES;
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
