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
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description;


@end
