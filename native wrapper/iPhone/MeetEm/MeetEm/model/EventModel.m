//
//  EventModel.m
//  whitewidow
//
//  Created by Paul Schmidt on 15.10.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "EventModel.h"
#import <Parse/PFObject.h>
#import <Parse/PFGeoPoint.h>
#import "UIWebviewInterfaceController.h"
#import "JSONHelper.h"
#import "LocationController.h"
#import "PushController.h"

@implementation EventModel

static id delegate;
+(void) setDelegate:(id)eventDelegate
{
    delegate = eventDelegate;
}

+(void) createEvent:(NSDictionary *)eventdata withAttendee:(NSString*) attendeeID
{
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    
    PFGeoPoint *coord = [PFGeoPoint geoPointWithLatitude:[[[eventdata valueForKey:@"location"] valueForKey:@"lat"] doubleValue] longitude:[[[eventdata valueForKey:@"location"] valueForKey:@"lng"] doubleValue]];
    [event setObject: coord forKey:@"location"];
    
    [event setObject: [eventdata valueForKey:@"id"] forKey:@"venueID"];
    [event setObject: [eventdata valueForKey:@"name"] forKey:@"venueName"];
    
    PFObject *host = [PFObject objectWithClassName:@"EventAttendees"];
    [host setObject:[NSNumber numberWithBool:YES] forKey:@"organisator"];
    [host setObject:[NSNumber numberWithInt:2] forKey:@"invitationState"];
    
    PFUser *user = [PFUser currentUser];
    [host setObject:user forKey:@"Attendee"];
    
    PFQuery* query = [PFUser query];
    [query whereKey:@"objectId" equalTo:attendeeID];
    
    
       
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        
        PFObject *attendee = [PFObject objectWithClassName:@"EventAttendees"];
        [attendee setObject:object forKey:@"Attendee"];
        [attendee setObject:[NSNumber numberWithInt:1] forKey:@"invitationState"];
        
        
        [event addObject:host forKey:@"attendees"];
        [event addObject:attendee forKey:@"attendees"];
        [event saveEventually:^(BOOL succeeded, NSError *error) {
            [PushController registerPushForEvent:event.objectId];
            [delegate eventSaved];
        }];
        
        
        NSString *channelID = @"friend_";
        channelID = [channelID stringByAppendingString:[user valueForKey:@"fbId"]];
        
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:channelID];
        NSString* pushMessage = [user valueForKey:@"facebookName"];
        pushMessage = [pushMessage stringByAppendingString:@" invited you to an event."];
        [push setMessage:pushMessage];
        [push sendPushInBackground];
        
        NSString* alertMessage = @"You will get a notification as soon as ";
        alertMessage = [alertMessage stringByAppendingString:[object valueForKey:@"facebookName"]];
        alertMessage = [alertMessage stringByAppendingString:@" has accepted."];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Invitation sent!" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show];
    }];
    
    
   /* [host saveEventually:^(BOOL succeeded, NSError *error)
     {
         if(succeeded)
         {
             LocationController *location = [[LocationController alloc] init];
             CLLocationCoordinate2D coord2d = CLLocationCoordinate2DMake( coord.latitude, coord.longitude);
             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
             NSString *eventChannel = @"event_";
             eventChannel = [eventChannel stringByAppendingString:event.objectId];
             [location registerForRegion:coord2d withRadius:100 withIdentifier:eventChannel];
             [currentInstallation addUniqueObject:eventChannel forKey:@"channels"];
             [currentInstallation saveEventually];*/
        /*}
     }];*/
}

+(void) modifyEvent:(NSString*) eventObj byId:(NSString*) eventID
{
    
}

+(PFObject*) getUpcomingEvent
{
    PFObject *event;
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    PFUser *user = [PFUser currentUser];
    PFQuery *innerquery = [PFQuery queryWithClassName:@"EventAttendees"];
    [innerquery whereKey:@"Attendee" equalTo:user];
    PFObject* attendee = [innerquery getFirstObject];
    
    
    [query whereKey:@"attendees" containsAllObjectsInArray:@[attendee]];
    [query includeKey:@"attendees"];
    [query includeKey:@"attendees.Attendee"];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:2];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *today = [calendar dateFromComponents:components];
    NSTimeInterval tomorrowDifference = 24*60*60;
    NSDate *tomorrow = [today dateByAddingTimeInterval:tomorrowDifference];
    
    [query whereKey:@"eventDate" greaterThan:today];
    [query whereKey:@"eventDate" lessThan:tomorrow];
    event = [query getFirstObject];
    
    return event;
}

+(PFObject*) getPendingEvent
{
    PFObject *event;
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    PFUser *user = [PFUser currentUser];
    PFQuery *innerquery = [PFQuery queryWithClassName:@"EventAttendees"];
    [innerquery whereKey:@"Attendee" equalTo:user];
    PFObject* attendee = [innerquery getFirstObject];
    
    
    [query whereKey:@"attendees" containsAllObjectsInArray:@[attendee]];
    [query includeKey:@"attendees"];
    [query includeKey:@"attendees.Attendee"];
    event = [query getFirstObject];
    
    return event;
}

+(void)deleteEvent:(NSString *)eventID
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:eventID block:^(PFObject *event, NSError *error)
     {
         // Delete Relation in EventAttendees
         [event deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
              if(succeeded)
              {
                  LocationController *location = [[LocationController alloc] init];
                  //CLLocationCoordinate2D coord2d = CLLocationCoordinate2DMake( coord.latitude, coord.longitude);
                  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                  NSString *eventChannel = @"event_";
                  //[location unregisterForRegion:coord2d withRadius:100 withIdentifier:eventChannel];
                  eventChannel = [eventChannel stringByAppendingString:eventID];
                  [currentInstallation removeObject:eventChannel forKey:@"channels"];
                  [currentInstallation saveEventually];
                  [dict setValue:@"success" forKey:@"state"];
              }
              else
              {
                  [dict setValue:@"failed" forKey:@"state"];
              }
              [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"deleteEvent"]];
          }];
     }];
}

+(void) getEventById:(NSString *) eventID
{
    PFQuery *query = [PFQuery queryWithClassName:@"EventAttendees"];
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" equalTo:eventID];
    [query whereKey:@"Event" matchesQuery:eventQuery];
    
    // Include the post data with each comment
    [query includeKey:@"Event"];
    [query includeKey:@"Attendee"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         NSMutableDictionary *dict;
         if(!error)
         {
             NSMutableArray *array = [[NSMutableArray alloc] init];
             
             for (PFObject *attendee in objects)
             {
                 // Eventdata
                 dict = [[NSMutableDictionary alloc] init];
                 PFObject *event = attendee[@"Event"];
                 [dict setValue:[event objectForKey:@"eventDate"] forKey:@"date"];
                 [dict setValue:event.createdAt forKey:@"createdAt"];
                 [dict setValue:event.updatedAt forKey:@"updatedAt"];
                 PFGeoPoint *coord = [event objectForKey:@"location"];
                 [dict setValue:[NSNumber numberWithDouble:coord.latitude] forKey:@"latitude"];
                 [dict setValue:[NSNumber numberWithDouble:coord.longitude] forKey:@"longitude"];
                 
                 [dict setValue:[attendee objectForKey:@"organisator"] forKey:@"organisator"];
                 PFObject *user = attendee[@"Attendee"];
                 [dict setValue:[user objectForKey:@"fbId"] forKey:@"fbId"];
                 [array addObject:dict];
             }
         }
         else
         {
             [dict setValue:@"failed" forKey:@"state"];
         }
         [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"createEvent"]];
     }];
}

+(BOOL) hasUnacceptedEvents
{
   /* PFQuery *query = [PFQuery queryWithClassName:@"EventAttendees"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"Attendee" equalTo:user];
    [query whereKey:@"invitationState" equalTo:[NSNumber numberWithInt:1]];
    
    int count = [query countObjects];
    if(count > 0)
    {
        return YES;
    }*/
    return NO;
}

+(BOOL) hasPendingEvents
{
   /* PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    PFUser *user = [PFUser currentUser];
    PFQuery *innerquery = [PFQuery queryWithClassName:@"EventAttendees"];
    [innerquery whereKey:@"Attendee" equalTo:user];
    [innerquery whereKey:@"invitationState" notEqualTo:[NSNumber numberWithInt:3]];
    PFObject* attendee = [innerquery getFirstObject];
    
    if(!attendee)
    {
        return NO;
    }
    [query whereKey:@"attendees" containsAllObjectsInArray:@[attendee]];
    [query whereKey:@"invitationState" equalTo:[NSNumber numberWithInt:1]];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:2];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *today = [calendar dateFromComponents:components];
    NSTimeInterval tomorrowDifference = 24*60*60;
    NSDate *tomorrow = [today dateByAddingTimeInterval:tomorrowDifference];
    
    [query whereKey:@"eventDate" greaterThan:today];
    [query whereKey:@"eventDate" lessThan:tomorrow];
    
    int count = [query countObjects];
    if(count > 0)
    {
        return YES;
    }*/
    return NO;
}

+(BOOL) hasUpcomingEvents
{
  /*  PFQuery *query = [PFQuery queryWithClassName:@"EventAttendees"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"Attendee" equalTo:user];
    [query whereKey:@"invitationState" equalTo:[NSNumber numberWithInt:2]];
    PFQuery *innerquery = [PFQuery queryWithClassName:@"EventAttendees"];
    [innerquery whereKey:@"invitationState" notEqualTo:[NSNumber numberWithInt:3]];
    [innerquery whereKey:@"Attendee" equalTo:user];
    NSArray* attendee = [innerquery findObjects];
    
    if(!attendee)
    {
        return NO;
    }
        
    [query whereKey:@"attendees" containsAllObjectsInArray:attendee];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:2];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *today = [calendar dateFromComponents:components];
    NSTimeInterval tomorrowDifference = 24*60*60;
    NSDate *tomorrow = [today dateByAddingTimeInterval:tomorrowDifference];
    
    [query whereKey:@"eventDate" greaterThan:today];
    [query whereKey:@"eventDate" lessThan:tomorrow];
    
    
    int count = [query countObjects];
    if(count > 0)
    {
        return YES;
    }*/
    return NO;
}

+(PFObject*) getUnacceptedEvents
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    PFUser *user = [PFUser currentUser];
    PFQuery *innerquery = [PFQuery queryWithClassName:@"EventAttendees"];
    [innerquery whereKey:@"Attendee" equalTo:user];
    PFObject* attendee = [innerquery getFirstObject];
    
    [query whereKey:@"attendees" containsAllObjectsInArray:@[attendee]];
    [query includeKey:@"attendees"];
    [query includeKey:@"attendees.Attendee"];
    PFObject* event = [query getFirstObject];
   // [query whereKey:@"invitationState" equalTo:[NSNumber numberWithInt:1]];
    
    return event;
}


+(void) getEventsFromUser:(NSString *) userID
{
    /*  PFQuery *innerQuery = [PFQuery queryWithClassName:@"EventAttendees"];
     PFUser *user = [PFUser currentUser];
     [innerQuery whereKey:@"Attendee" equalTo:user];
     PFQuery *query = [PFQuery queryWithClassName:@"Event"];
     [query getObjectInBackgroundWithId:eventID block:^(PFObject *event, NSError *error)
     {
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
     if(!error)
     {
     
     }
     else
     {
     [dict setValue:@"failed" forKey:@"state"];
     }
     [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"createEvent"]];
     }];*/
}

+(void) attendEvent:(NSString *) eventID
{
    PFObject *attendee = [PFObject objectWithClassName:@"EventAttendees"];
    attendee[@"Event"] = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventID];
    attendee[@"Attendee"] = [PFUser currentUser];
    [attendee setObject:[NSNumber numberWithBool:NO] forKey:@"organisator"];
    [attendee saveEventually:^(BOOL succeeded, NSError *error)
     {
         NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
         if(succeeded)
         {
             PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
             [eventQuery getObjectInBackgroundWithId:eventID block:^(PFObject *object, NSError *error)
              {
                  LocationController *location = [[LocationController alloc] init];
                  PFGeoPoint *coord = [object objectForKey:@"location"];
                  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                  NSString *eventChannel = @"event_";
                  eventChannel = [eventChannel stringByAppendingString:eventID];
                  
                  CLLocationCoordinate2D coord2d = CLLocationCoordinate2DMake( coord.latitude, coord.longitude);
                  [location registerForRegion:coord2d withRadius:100 withIdentifier:eventChannel];
                  [currentInstallation addUniqueObject:eventChannel forKey:@"channels"];
                  [currentInstallation saveEventually];
                  [dict setValue:@"success" forKey:@"state"];
              }];
         }
         else
         {
             [dict setValue:@"failed" forKey:@"state"];
         }
         [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"attendEvent"]];
         
     }];
}

+(void) leaveEvent:(NSString *) eventID
{
    
    PFQuery *deleteQuery = [PFQuery queryWithClassName:@"EventAttendees"];
    [deleteQuery getObjectInBackgroundWithId:eventID block:^(PFObject *object, NSError *error)
     {
         NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
         if(error == nil)
         {
             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
             NSString *eventChannel = @"event_";
             eventChannel = [eventChannel stringByAppendingString:eventID];
             [currentInstallation addUniqueObject:eventChannel forKey:@"channels"];
             [currentInstallation saveEventually];
             [object deleteEventually];
             [dict setValue:@"success" forKey:@"state"];
         }
         else
         {
             [dict setValue:@"failed" forKey:@"state"];
         }
         [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"attendEvent"]];
         
     }];
}

@end
