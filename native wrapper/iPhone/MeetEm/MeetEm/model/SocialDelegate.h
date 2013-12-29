//
//  SocialDelegate.h
//  Whitewidow
//
//  Created by Paul Schmidt on 21.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocialDelegate <NSObject>
-(void) setFriendsList:(NSArray *) friends;
-(void) setFriendsListOfConnectedUsers:(NSArray *) friends;
-(void) setInvitationList:(NSArray*)invites;
-(void) setWWFriendList:(NSArray*)friends;
@end
