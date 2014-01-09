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
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
    }
    return self;
}
@end
