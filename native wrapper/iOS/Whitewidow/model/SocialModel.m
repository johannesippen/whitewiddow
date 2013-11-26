//
//  SocialController.m
//  Whitewidow
//
//  Created by Paul Schmidt on 20.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "SocialModel.h"
#import <Social/Social.h>
#import <Parse/Parse.h>
#import "JSONHelper.h"
#import "UIWebviewInterfaceController.h"
#import "Logger.h"
#import "TestFlight.h"
#import "PushController.h"

@interface SocialModel()
@property NSMutableArray *invitationList;
@end

@implementation SocialModel
@synthesize delegate;

- (void) connect:(NSString*) withNetwork
{
    NSArray *permissionsArray = @[ @"user_about_me", @"friends_about_me"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                [Logger logMessage:@"User Canceled Facebook login" withScope:@"Social"];
                [dict setValue:@"UserCanceled" forKey:@"connectionState"];
            } else {
                [Logger logMessage:@"Login Error" withScope:@"Social"];
                NSRange stringRange = [[error description] rangeOfString:@"UserLoginCancelled"];
                if(stringRange.length != 0)
                {
                    [dict setValue:@"UserCanceled" forKey:@"connectionState"];
                }
                else
                {
                    [dict setValue:@"Error" forKey:@"connectionState"];
                }
            }
        } else if (user.isNew) {
            [TestFlight passCheckpoint:@"Facebook authorized"];
            [Logger logMessage:@"Login Logged in and signed up" withScope:@"Social"];
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"fbId"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"name"]
                                             forKey:@"facebookName"];
                    [[PFUser currentUser] saveEventually];
                    [dict setValue:@"SignedUp" forKey:@"connectionState"];
                }
            }];
        } else {
            [dict setValue:@"LoggedIn" forKey:@"connectionState"];
            [Logger logMessage:@"Logged in" withScope:@"Social"];
            [TestFlight passCheckpoint:@"Facebook authorized"];
        }
        [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"connectFB"]];
    }];

}

- (void) saveCurrentState: (NSString*) state
{
    if([PFUser currentUser] != nil)
    {
        PFObject* currentLocation = [PFObject objectWithClassName:@"UserAvailability"];
        [currentLocation setObject:[PFUser currentUser] forKey:@"user"];
        [currentLocation setObject:[NSNumber numberWithInt:[self convertToAvailability:state]] forKey:@"availability"];
        [currentLocation saveEventually];
        
        PFUser* lastLocation = [PFUser currentUser];
        [lastLocation setValue:[NSNumber numberWithInt:[self convertToAvailability:state]] forKey:@"currentAvailability"];
        [lastLocation saveEventually];
    }
}

- (void) getWWFriendsList
{
    if([PFUser currentUser] != nil)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"FriendsConnection"];
        
        [query includeKey:@"Friend"];
        [query whereKey:@"User" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if(error == nil)
            {
                NSMutableArray* friends = [[NSMutableArray alloc] initWithArray:objects];
                __block NSMutableDictionary *friend;
                for (int i = 0; i < objects.count; i++)
                {
                    friend = [[NSMutableDictionary alloc] init];
                    [friend setValue:objects[i][@"objectId"] forKey:@"objectId"];
                    [friend setValue:objects[i][@"facebookName"] forKey:@"name"];
                    [friend setValue:@"accepted" forKey:@"invitationState"];
                    [friend setValue:objects[i][@"fbId"] forKey:@"fbID"];
                    [friend setValue:objects[i][@"lastLocation"] forKey:@"location"];
                    int currentAvailability = [objects[i][@"currentAvailability"] integerValue];
                    [friend setValue:[self convertToReadableAvailability: currentAvailability] forKey:@"availability"];
                    [friends addObject:friend];
                }
                
                PFQuery *invitationQuery = [PFQuery queryWithClassName:@"UserInvitations"];
                [invitationQuery whereKey:@"invitationFrom" equalTo:[PFUser currentUser]];
                [invitationQuery findObjectsInBackgroundWithBlock:^(NSArray *invitations, NSError *invitationError)
                 {
                     if(invitationError == nil)
                     {
                         int invitationState;
                         for (int j = 0; j < invitations.count; j++)
                         {
                             friend = [[NSMutableDictionary alloc] init];
                             [friend setValue:invitations[j][@"objectId"] forKey:@"objectId"];
                             [friend setValue:invitations[j][@"facebookName"] forKey:@"name"];
                             invitationState = [[invitations[j] valueForKey:@"invitationState"] integerValue];
                             [friend setValue:[self convertToReadableState:invitationState] forKey:@"invitationState"];
                             [friend setValue:invitations[j][@"fbID"] forKey:@"fbID"];
                             [friend setValue:@"notdetermined" forKey:@"location"];
                             [friend setValue:@"notdetermined" forKey:@"availability"];
                             [friends addObject:friend];
                         }
                         if(self.delegate != nil)
                         {
                             [self.delegate setWWFriendList:friends];
                         }
                         [UIWebviewInterfaceController callJavascript:[JSONHelper convertArrayToJSON:friends forSignal:@"getWWFriendsList"]];
                     }
                 }];
            }
        }];
    }
}

- (void)setDelegate:(id <SocialDelegate>)aDelegate {
    if (delegate != aDelegate)
    {
        delegate = aDelegate;
    }
}



- (void) setFriendsListOfConnectedUsers:(NSArray *)friends
{
    [UIWebviewInterfaceController callJavascript:[JSONHelper convertArrayToJSON:friends forSignal:@"getConnectedFBContacts"]];
}

- (void) getFriendsListOfConnectedFriends
{
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSArray *friendUsers = [friendQuery findObjects];
            [self setFriendsListOfConnectedUsers:friendUsers];
        }
    }];
}

- (void) setFriendsList:(NSArray *)friends
{
    if(self.delegate != nil)
    {
        [self.delegate setFriendsList:friends];
    }
   // [UIWebviewInterfaceController callJavascript:[JSONHelper convertArrayToJSON:friends forSignal:@"getFBContacts"]];
}

- (void) setInvitationState:(NSString*)state forID:(NSString*) invitationID
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserInvitations"];
    [query getObjectInBackgroundWithId:invitationID block:^(PFObject *userInvitation, NSError *error) {
        
        
        PFObject *user = [PFUser currentUser];
        // Changes the invitation status, 0 = pending, 1 = accepted, 2 = denied
        int invitationState;
        
        if ([state isEqualToString:@"pending"])
        {
            invitationState = 0;
        }
        else if([state isEqualToString:@"accepted"])
        {
            invitationState = 1;
        }
        else
        {
            invitationState = 2;
        }
        
        userInvitation[@"invitationState"] = [NSNumber numberWithInt:invitationState];
        [userInvitation saveEventually:^(BOOL succeeded, NSError *error)
        {
            NSString* username = [user valueForKey:@"facebookName"];
            NSString *pushMessage;
            if(invitationState == 1)
            {
                pushMessage = [username stringByAppendingString:@" hat deine Freundschaftsanfrage angenommen."];
            }
            else{
                pushMessage = [username stringByAppendingString:@" hat deine Freundschaftsanfrage abgelehnt."];
            }
            NSString *channelID = @"invite_";
            [channelID stringByAppendingString:userInvitation.objectId];
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:channelID];
            [push setMessage:pushMessage];
            [push sendPushInBackground];
        }];
        
        // Saves the Connection between the two users
        if(invitationState == 1)
        {
            PFObject *friend = [userInvitation objectForKey:@"invitationFrom"];
            
            PFObject *friendToUserConnection = [PFObject objectWithClassName:@"UserConnection"];
            [friendToUserConnection setObject:friend forKey:@"friend"];
            [friendToUserConnection setObject:user forKey:@"user"];
            [friendToUserConnection saveEventually];
            
            PFObject *userToFriendConnection = [PFObject objectWithClassName:@"UserConnection"];
            [userToFriendConnection setObject:user forKey:@"friend"];
            [userToFriendConnection setObject:friend forKey:@"user"];
            [userToFriendConnection saveEventually];
            
           
        }
             
        
    }];
}

- (void) inviteFBUserById:(NSString* )fbId
{
    NSString *fbGraphpath = fbId;
    fbGraphpath = [fbGraphpath stringByAppendingString:@"?fields=id,name"];
    FBRequest *request = [FBRequest requestForGraphPath:fbGraphpath];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if(error == nil)
        {
            PFUser *user = [PFUser currentUser];
            PFObject *userInvitation = [PFObject objectWithClassName:@"UserInvitations"];
            [userInvitation setObject:fbId forKey:@"fbID"];
            [userInvitation setObject:result[@"name"] forKey:@"facebookName"];
            [userInvitation setObject:user forKey:@"invitationFrom"];
            [userInvitation setObject:[NSNumber numberWithInt:0] forKey:@"invitationState"];
            [userInvitation saveEventually:^(BOOL succeeded, NSError *error) {
                if(succeeded)
                {
                    NSString* objectID = userInvitation.objectId;
                    [PushController registerPushForInvite:objectID];
                    
                   // FBRequest *inviteRequest = [FBRequest ]
                }
            }];
    //
        }
    }];
}

- (void) getInvitationsForMe
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserInvitations"];
    NSString *fbID = [[PFUser currentUser] valueForKey:@"fbId"];
    [query whereKey:@"fbID" equalTo:fbID];
    [query whereKey:@"invitationState" equalTo:[NSNumber numberWithInt:1]];
    [query includeKey:@"invitationFrom"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if(error == nil)
        {
            NSMutableArray* invites = [[NSMutableArray alloc]init];
            NSMutableDictionary *invite;
            for (int i = 0; i < objects.count; i++)
            {
                invite = [[NSMutableDictionary alloc] init];
                [invite setValue:[objects[i] valueForKey:@"objectId"] forKey:@"objectId"];
                [invite setValue:[objects[i] valueForKey:@"objectId"] forKey:@"objectId"];
                [invites addObject:invite];
            }
        }
    }];
}

- (void) getInvitedUser
{
    // Facebookfriends auslesen
    __block PFUser *user = [PFUser currentUser];
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary* result, NSError *error)
     {
         if(error == nil)
         {
             // Bereits eingeladene Freunde auslesen
             PFQuery *inviteQuery = [PFQuery queryWithClassName:@"UserInvitations"];
             [inviteQuery whereKey:@"invitationFrom" equalTo:user];
             NSArray *invites = [inviteQuery findObjects];
             
             if (_invitationList == nil)
             {
                 _invitationList = [[NSMutableArray alloc] init];
             }
             
             PFQuery *myPendingInvitationsQuery = [PFQuery queryWithClassName:@"UserInvitations"];
             [myPendingInvitationsQuery whereKey:@"fbID" equalTo:[user valueForKey:@"fbId"]];
             [myPendingInvitationsQuery includeKey:@"invitationFrom"];
             
             NSArray *myPendingInvitations = [myPendingInvitationsQuery findObjects];
             
             NSMutableDictionary* userInvitation;
             NSString* facebookID;
             int invitationState;
             for (FBGraphObject* facebookUser in result[@"data"])
             {
                 userInvitation = [[NSMutableDictionary alloc] init];
                 facebookID = [facebookUser valueForKey:@"id"];
                 [userInvitation setValue:facebookID forKey:@"fbID"];
                 [userInvitation setValue:[facebookUser valueForKey:@"name"] forKey:@"name"];
                 for (PFObject *object in invites)
                 {
                     if([facebookID isEqualToString:[object valueForKey:@"fbID"]])
                     {
                         invitationState = [[object valueForKey:@"invitationState"] integerValue];
                         [userInvitation setValue:[self convertToReadableState:invitationState] forKey:@"invitationState"];
                         break;
                     }
                     else
                     {
                         [userInvitation setValue:@"notdetermined" forKey:@"invitationState"];
                     }
                 }
                 
                 for (PFObject *pendingInvitation in myPendingInvitations)
                 {
                     NSString* pendingUser = [[pendingInvitation valueForKey:@"invitationFrom"] valueForKey:@"fbId"];
                     
                     if([facebookID isEqualToString:pendingUser])
                     {
                         [userInvitation setValue:@"pendingByMe" forKey:@"invitationState"];
                         break;
                     }
                 }
                 
                 [_invitationList addObject:userInvitation];
             }
             if(self.delegate != nil)
             {
                 [self.delegate setInvitationList:_invitationList];
             }
             [UIWebviewInterfaceController callJavascript:[JSONHelper convertArrayToJSON:_invitationList forSignal:@"getInvitedUser"]];
         }
     }];
}

-(NSString*) convertToReadableAvailability: (int) availability
{
    NSString* availabilityState;
    switch(availability)
    {
        case -1:
            availabilityState = @"notdetermined";
            break;
        case 0:
            availabilityState = @"free";
            break;
        case 1:
            availabilityState = @"busy";
            break;
    }
    return availabilityState;
}

-(int) convertToAvailability: (NSString*) availability
{
    int availabilityState;
    if([availability isEqualToString:@"notdetermined"])
    {
        availabilityState = -1;
    }
    else if ([availability isEqualToString:@"free"])
    {
        availabilityState = 0;
    }
    else
    {
        availabilityState = 1;
    }
    return availabilityState;
}

-(NSString*) convertToReadableState: (int) state
{
    NSString* invitationState;
    switch(state)
    {
        case -1:
            invitationState = @"notdetermined";
            break;
        case 0:
            invitationState = @"pending";
            break;
        case 1:
            invitationState = @"accepted";
            break;
        case 2:
            invitationState = @"denied";
            break;
    }
    return invitationState;
}

- (void) getFriendsList
{
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary* result, NSError *error)
    {
        if (!error)
        {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friends = [result objectForKey:@"data"];
            NSString *log = @"Get Facebook Friends:";
            [Logger logMessage:log withScope:@"Social"];
            [self setFriendsList:friends];
        }
        else
        {
            [Logger logMessage:@"ERROR: cannot retrieve FB Friendslist" withScope:@"Social"];
        }
    }];
}

- (void) getUserData
{
    PFObject* user = [PFUser currentUser];
    if(user != nil)
    {
        NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
        
        [userData setValue:user[@"objectId"] forKey:@"objectId"];
        [userData setValue:user[@"facebookName"] forKey:@"name"];
        [userData setValue:user[@"fbId"] forKey:@"fbID"];
        [userData setValue:@"notdetermined" forKey:@"location"];
        [userData setValue:@"notdetermined" forKey:@"availability"];
        
        [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:userData forSignal:@"getUserData"]];
    }
}
@end
