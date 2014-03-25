//
//  EventVO.h
//  MeetEm
//
//  Created by Paul Schmidt on 19.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/PFObject.h>
#import <Parse/PFGeoPoint.h>
#import <Parse/PFUser.h>
#import "EventAttendeeVO.h"

@interface EventVO : NSObject

@property (retain, readonly) NSString* venueName;
@property (readonly) CLLocationCoordinate2D location;
@property (retain, readonly) NSString* venueID;
@property (retain, readonly) NSDate* eventDate;
@property (retain, readonly) NSString* objectId;
@property (retain, readonly) NSMutableArray* attendees;
@property (retain, readonly) EventAttendeeVO* organisator;
@property (readonly) BOOL isCurrentuserOrganisator;
@property (retain, readonly) EventAttendeeVO* currentUser;
@property (retain, readonly) EventAttendeeVO* friend;

@property (retain, readonly) PFObject* object;

-(id) initWithData:(PFObject*) data;

@end
