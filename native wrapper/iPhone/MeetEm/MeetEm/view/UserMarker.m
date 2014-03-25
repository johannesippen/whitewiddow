//
//  UserMarker.m
//  MeetEm
//
//  Created by Paul Schmidt on 09.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "UserMarker.h"

@implementation UserMarker
@synthesize coordinate;
@synthesize title;
@synthesize availability;
@synthesize markerType;
@synthesize index;


- (id)initWithCoordinates:(CLLocationCoordinate2D)location userID:(NSString*)userID availability:(int)avail {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = userID;
        availability = avail;
        index = -1;
    }
    return self;
}
@end
