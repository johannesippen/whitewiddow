//
//  AppDelegate.m
//  Whitewidow
//
//  Created by Paul Schmidt on 11.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "TestFlight.h"
#import "PushController.h"
#import "SocialModel.h"
#import "LocationController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"b7e77ee3-f211-47e6-8c99-7075c501a9f1"];
    [Parse setApplicationId:@"KNtdMcnjzZUcsSLkPVvbW7lakdF9hzitvFaDjmU1"
                  clientKey:@"5mTRyvLWqb6eEZelvR2GhmNgbzddGr2s8x5hB37P"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    [NSClassFromString(@"WebView") performSelector:@selector(_enableRemoteInspector)];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    SocialModel *social = [[SocialModel alloc] init];
    
    [social getWWFriendsList];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"registerNotification");
    [TestFlight passCheckpoint:@"Pushnotifications registered"];
    // Store the deviceToken in the current Installation and save it to Parse.
    [PFPush storeDeviceToken:deviceToken];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"failNotification: %@", error);
    [TestFlight passCheckpoint:@"Pushnotifications failed"];
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
    LocationController* localCtrl = [[LocationController alloc] init];
    [localCtrl saveCurrentLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
