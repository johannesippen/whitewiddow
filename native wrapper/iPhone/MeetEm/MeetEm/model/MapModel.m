//
//  MapModel.m
//  MeetEm
//
//  Created by Paul Schmidt on 09.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "MapModel.h"
#import "UserMarker.h"

@implementation MapModel

static MKMapView* map;
static UserMarker* annotation;

+ (void)showMap
{
    if(map)
    {
        [map setHidden:NO];
    }
}

+ (void)hideMap
{
    if(map)
    {
        [map setHidden:YES];
    }
}

+ (void)setMapView:(MKMapView*) mapView
{
    map = mapView;
    [map showsUserLocation];
}

+ (void)addMarker:(NSString*) mapObj
{
    mapObj = [mapObj stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *mapdata = [NSJSONSerialization
                               JSONObjectWithData:[mapObj dataUsingEncoding:NSUTF8StringEncoding]
                               options:kNilOptions
                               error:nil];
    CLLocationDegrees lat = [[mapdata valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[mapdata valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
    UserMarker *pin = [[UserMarker alloc] initWithCoordinates:location placeName:@"" description:@""];
    
    [map setShowsUserLocation:YES];
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    CLLocationCoordinate2D userLocation = manager.location.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(lat - userLocation.latitude, lon - userLocation.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake([MapModel findCenterPoint:location :userLocation], span);
    region.span.latitudeDelta  *= 1.3;
    region.span.longitudeDelta  *= 1.3;
    
    [map setRegion:region];
    
    [map removeAnnotation:annotation];
    annotation = pin;
    [map addAnnotation:pin];
}

+(CLLocationCoordinate2D)findCenterPoint:(CLLocationCoordinate2D)_lo1 :(CLLocationCoordinate2D)_loc2 {
    CLLocationCoordinate2D center;
    
    double lon1 = _lo1.longitude * M_PI / 180;
    double lon2 = _loc2.longitude * M_PI / 180;
    
    double lat1 = _lo1.latitude * M_PI / 180;
    double lat2 = _loc2.latitude * M_PI / 180;
    
    double dLon = lon2 - lon1;
    
    double x = cos(lat2) * cos(dLon);
    double y = cos(lat2) * sin(dLon);
    
    double lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) );
    double lon3 = lon1 + atan2(y, cos(lat1) + x);
    
    center.latitude  = lat3 * 180 / M_PI;
    center.longitude = lon3 * 180 / M_PI;
    
    return center;
}

@end
