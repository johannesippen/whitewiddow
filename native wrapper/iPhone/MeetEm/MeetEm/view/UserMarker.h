//
//  UserMarker.h
//  MeetEm
//
//  Created by Paul Schmidt on 09.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UserMarker : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    int availability;
    
    NSString *markerType;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) int availability;
@property (nonatomic) int index;
@property (nonatomic, readonly) NSString *markerType;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location userID:(NSString*)userID availability:(int)avail;


@end
