//
//  PushController.m
//  Whitewidow
//
//  Created by Paul Schmidt on 15.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "PushController.h"
#import <Parse/PFInstallation.h>
#import "TestFlight.h"

@interface PushController()
@property NSDictionary *regions;

@end


@implementation PushController

+ (BOOL) isPushEnabled
{
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if(types == UIRemoteNotificationTypeNone)
        return NO;
    else
        return YES;
}

+ (void)enablePushNotification
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [TestFlight passCheckpoint:@"PushNotification enabled"];
}

- (NSString *) getIdentfierForRegion:(CLRegion *)region
{
    NSString *key;
    NSString *identifier;
    for (key in self.regions)
    {
        if (region == [self.regions objectForKey:key])
        {
            identifier = key;
            break;
        }
    }
    return identifier;
}

-(void) setIdentifier: (NSString *) identifier forRegion: (CLRegion *) region
{
    [self.regions setValue:region forKey:identifier];
    [self registerPushForRegion: identifier];
}

-(void) removeRegionByIdentifier: (NSString *) identifier
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:identifier forKey:@"Channels"];
    [currentInstallation saveInBackground];
}

-(void) registerPushForRegion: (NSString *)identifier
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:identifier forKey:@"channels"];
    [currentInstallation saveInBackground];
}

+(void) registerPushForInvite: (NSString*) inviteID
{
    NSString* identifier = @"invite_";
    identifier = [identifier stringByAppendingString:inviteID];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:identifier forKey:@"channels"];
    [currentInstallation saveInBackground];
}

+(void) registerPushForFriend: (NSString *) friendID
{
    NSString* identifier = @"friend_";
    identifier = [identifier stringByAppendingString:friendID];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:identifier forKey:@"channels"];
    [currentInstallation saveInBackground];
}

+(void) registerPushForEvent: (NSString *) eventID
{
    NSString* identifier = @"event_";
    identifier = [identifier stringByAppendingString:eventID];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:identifier forKey:@"channels"];
    [currentInstallation saveInBackground];
}

+(void) unregisterPushForInvite: (NSString*) inviteID
{
    NSString* identifier = @"invite_";
    [identifier stringByAppendingString:inviteID];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:identifier forKey:@"Channels"];
    [currentInstallation saveInBackground];
}

@end
