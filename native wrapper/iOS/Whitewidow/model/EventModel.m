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

@implementation EventModel

+(void) createEvent:(NSString *)eventObj
{
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    eventObj = [eventObj stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *eventdata = [NSJSONSerialization
                              JSONObjectWithData:[eventObj dataUsingEncoding:NSUTF8StringEncoding]
                              options:kNilOptions
                              error:nil];
    PFGeoPoint *coord = [PFGeoPoint geoPointWithLatitude:[[eventdata valueForKey:@"latitude"] doubleValue] longitude:[[eventdata valueForKey:@"longitude"] doubleValue]];
    [event setObject: coord forKey:@"location"];
    NSDate *eventDate = [JSONHelper dateWithJSONString:[eventdata valueForKey:@"date"]];
    [event setObject: eventDate forKey:@"eventDate"];
    
    PFObject *host = [PFObject objectWithClassName:@"EventAttendees"];
    [host setObject:[NSNumber numberWithBool:YES] forKey:@"organisator"];
    [host setObject:event forKey:@"Event"];
    
    PFUser *user = [PFUser currentUser];
    [host setObject:user forKey:@"Attendee"];
    
    [host saveEventually:^(BOOL succeeded, NSError *error)
     {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        if(succeeded)
        {
            LocationController *location = [[LocationController alloc] init];
            CLLocationCoordinate2D coord2d = CLLocationCoordinate2DMake( coord.latitude, coord.longitude);
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            NSString *eventChannel = @"event_";
            eventChannel = [eventChannel stringByAppendingString:event.objectId];
            [location registerForRegion:coord2d withRadius:100 withIdentifier:eventChannel];
            [currentInstallation addUniqueObject:eventChannel forKey:@"channels"];
            [currentInstallation saveEventually];
            [dict setValue:@"success" forKey:@"state"];
        }
        else
        {
            [dict setValue:@"failed" forKey:@"state"];
        }
        [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"createEvent"]];
    }];
}

+(void) modifyEvent:(NSString*) eventObj byId:(NSString*) eventID
{
    
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
