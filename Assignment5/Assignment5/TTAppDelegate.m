//
//  TTAppDelegate.m
//  Assignment5
//
//  Created by ch484-mac5 on 3/26/14.
//  Copyright (c) 2014 ch484-mac5. All rights reserved.
//

#import "TTAppDelegate.h"

@implementation TTAppDelegate

#pragma mark - BLE Delegate
-(void) bleDidConnect
{
    NSLog(@"BLE Connected");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDidConnected" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Hey", @"String", nil]];
}
-(void) bleDidDisconnect
{
    NSLog(@"BLE DisConnected");
}
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    NSLog(@"BLE Update RSSI");
}
-(void) bleDidReceiveData:(unsigned char *) data length:(int) length
{
    NSLog(@"BLE ReceiveData");
}

#pragma mark - Application Deletate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    
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
