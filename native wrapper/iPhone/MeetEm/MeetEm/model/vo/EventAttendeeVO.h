//
//  EventAttendeeVO.h
//  MeetEm
//
//  Created by Paul Schmidt on 19.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/PFObject.h>
#import <Parse/PFGeoPoint.h>
#import <Parse/PFUser.h>
#import <CoreLocation/CoreLocation.h>

@interface EventAttendeeVO : NSObject
@property (retain, readonly) NSString* objectId;
@property (readonly) int invitationState;
@property (readonly) BOOL organisator;
@property (readonly) BOOL cancelationReadPending;
@property (retain, readonly) NSString* facebookName;
@property (readonly) CLLocationCoordinate2D location;
@property (retain, readonly) NSString* fbId;
@property (readonly) int availability;
@property (readonly, retain) NSDate* lastAvailability;
@property (readonly, retain) PFObject* object;

-(id) initWithData:(PFObject*) data;
@end
