//
//  EventModel.h
//  whitewidow
//
//  Created by Paul Schmidt on 15.10.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventModel : NSObject
+(void) createEvent:(NSString*) eventObj;
+(void) modifyEvent:(NSString*) eventObj byId:(NSString*) eventID;
+(void) deleteEvent:(NSString*) eventID;
+(void) getEventById:(NSString *) eventID;
+(void) getEventsFromUser:(NSString *) userID;
+(void) attendEvent:(NSString *) eventID;
+(void) leaveEvent:(NSString *) eventID;
@end
