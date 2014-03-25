//
//  EventAttendeeVO.m
//  MeetEm
//
//  Created by Paul Schmidt on 19.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "EventAttendeeVO.h"

@implementation EventAttendeeVO

@synthesize objectId;
@synthesize invitationState;
@synthesize organisator;
@synthesize cancelationReadPending;
@synthesize facebookName;
@synthesize location;
@synthesize fbId;
@synthesize availability;
@synthesize lastAvailability;
@synthesize object;

-(id) initWithData:(PFObject*) data
{
    object = data;
    objectId = [data valueForKey:@"objectId"];
    invitationState = (int)[data valueForKey:@"invitationState"];
    organisator = (BOOL)[data valueForKey:@"organisator"];
    cancelationReadPending = (BOOL)[data valueForKey:@"cancelationReadPending"];
    
    facebookName = [[data valueForKey:@"Attendee"] valueForKey:@"facebookName"];
    fbId = [[data valueForKey:@"Attendee"] valueForKey:@"fbId"];
    PFGeoPoint* geoPoint = [[data valueForKey:@"Attendee"] valueForKey:@"lastLocation"];
    location = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    
    availability = (int)[[data valueForKey:@"Attendee"] valueForKey:@"currentAvailability"];
    lastAvailability = [[data valueForKey:@"Attendee"] valueForKey:@"lastAvailability"];
    
    return self;
}

-(CLLocationCoordinate2D) location
{
    if ([objectId isEqualToString:[PFUser currentUser].objectId])
    {
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        return [[manager location] coordinate];
    }
    else
    {
        return location;
    }
}

@end
