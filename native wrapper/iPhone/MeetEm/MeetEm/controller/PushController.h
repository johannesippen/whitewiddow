//
//  PushController.h
//  Whitewidow
//
//  Created by Paul Schmidt on 15.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLRegion.h>

@interface PushController : NSObject

-(NSString *) getIdentfierForRegion: (CLRegion *) region;
-(void) setIdentifier: (NSString *) identifier forRegion: (CLRegion *) region;
-(void) registerPushForRegion: (NSString *) identifier;

+ (BOOL) isPushEnabled;
+ (void) enablePushNotification;

+(void) registerPushForFriend: (NSString *) friendID;
+(void) registerPushForInvite: (NSString*) inviteID;

@end
