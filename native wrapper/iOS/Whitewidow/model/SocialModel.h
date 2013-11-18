//
//  SocialController.h
//  Whitewidow
//
//  Created by Paul Schmidt on 20.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialDelegate.h"

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
- (void) setInvitationState:(NSString*)state forID:(NSString*) invitationID;

@end
