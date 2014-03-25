//
//  SocialController.h
//  Whitewidow
//
//  Created by Paul Schmidt on 20.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialDelegate.h"
#import <Parse/PFObject.h>

typedef NS_ENUM(NSInteger, InvitationState) {
	InvitationStateNotDetermined = -1,
	InvitationStatePending = 0,
	InvitationStateAccepted = 1,
    InvitationStateDenied = 2
};

@interface SocialModel : NSObject<SocialDelegate>
@property (nonatomic, weak) id <SocialDelegate> delegate;



- (void) connect:(NSString*) withNetwork;
- (void) getFriendsList;
- (void) getUserData;
- (void) getFriendsListOfConnectedFriends;
- (void) getWWFriendsList;
- (void) inviteFBUserById:(NSString* )fbId;
- (void) getInvitedUser;
- (void) saveCurrentState: (NSString*) state;
- (void) setInvitationState:(NSString*)message;
+ (int) getCurrentAvailabilityFromUser:(int) availability withDate:(NSDate*) date;

@end
