//
//  EventModel.h
//  whitewidow
//
//  Created by Paul Schmidt on 15.10.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "EventViewController.h"

@interface EventModel : NSObject

typedef NS_ENUM(NSInteger, EventState)
{
    EventStateNothing,
    EventStatePending,
    EventStateRequested,
    EventStateUpcoming,
    EventStateRunning
};

+(void) createEvent:(NSDictionary *)eventdata withAttendee:(NSString*) attendeeID;
+(void) modifyEvent:(NSString*) eventObj byId:(NSString*) eventID;
+(void) deleteEvent:(NSString*) eventID;
+(void) getEventById:(NSString *) eventID;
+(void) getEventsFromUser:(NSString *) userID;
+(void) attendEvent:(NSString *) eventID;
+(void) leaveEvent:(NSString *) eventID;
+(BOOL) hasUnacceptedEvents;
+(BOOL) hasUpcomingEvents;
+(BOOL) hasPendingEvents;
+(PFObject*) getPendingEvent;
+(PFObject*) getUnacceptedEvents;
+(PFObject*) getUpcomingEvent;
+(void) setDelegate:(EventViewController*)eventDelegate;
@end
