//
//  EventVO.m
//  MeetEm
//
//  Created by Paul Schmidt on 19.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "EventVO.h"

@implementation EventVO

@synthesize objectId;
@synthesize venueName;
@synthesize venueID;
@synthesize location;
@synthesize eventDate;
@synthesize attendees;
@synthesize organisator;
@synthesize currentUser;
@synthesize isCurrentuserOrganisator;
@synthesize friend;
@synthesize object;

-(id) initWithData:(PFObject*) data
{
    object = data;
    objectId = [data valueForKey:@"objectId"];
    venueID = [data valueForKey:@"venueID"];
    venueName = [data valueForKey:@"venueName"];
    location = CLLocationCoordinate2DMake([[(PFGeoPoint*)data valueForKey:@"location"] latitude], [[(PFGeoPoint*)data valueForKey:@"location"] longitude]);
    eventDate = [data valueForKey:@"eventData"];
    
    attendees = [[NSMutableArray alloc] init];
    
    EventAttendeeVO* attendeeVO;
    NSArray* attendeeList = [data valueForKey:@"attendees"];
    for (int i = 0; i < attendeeList.count; ++i)
    {
        attendeeVO = [[EventAttendeeVO alloc] initWithData:attendeeList[i]];
        
        if (attendeeVO.organisator)
        {
            organisator = attendeeVO;
        }
        
        if([attendeeVO.objectId isEqualToString: [PFUser currentUser].objectId])
        {
            currentUser = attendeeVO;
            if(attendeeVO.organisator)
            {
                isCurrentuserOrganisator = YES;
            }
            else
            {
                isCurrentuserOrganisator = NO;
            }
        }
        else
        {
            friend = attendeeVO;
        }
        
        [attendees addObject:attendeeVO];
    }
    
    return self;
}

@end
