//
//  LocationUtils.h
//  MeetEm
//
//  Created by Paul Schmidt on 16.02.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationUtilsDelegate.h"
#import <Parse/Parse.h>

@interface LocationUtils : NSObject

+(CLLocationCoordinate2D)findCenterPoint:(CLLocationCoordinate2D)_lo1 :(CLLocationCoordinate2D)_loc2;
+(void) getVenueForFriend:(NSString*)friend;
+(void) setDelegate:(id)locationUtilsDelegate;
+(NSString*) formatDistance: (CLLocationCoordinate2D)geoPoint;

@end
