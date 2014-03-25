//
//  MapModel.h
//  MeetEm
//
//  Created by Paul Schmidt on 09.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "EventViewController.h"
#import "LocationUtilsDelegate.h"
#import "EventViewControllerDelegate.h"

@interface MapModel : NSObject<MKMapViewDelegate, LocationUtilsDelegate>


+ (NSDictionary*) getCurrentVenue;
+ (void)showMap;
+ (void)hideMap;
+ (void)setMapView:(MKMapView*) mapView;
+ (void)addMarker:(CLLocationDegrees)lat atLongitude:(CLLocationDegrees)lon;
+ (void)addMarker:(NSString*)me withAvailability:(int) availability;
+ (void)addMarker:(CLLocationDegrees)lat atLongitude:(CLLocationDegrees)lon forFriend:(NSString*)friend withAvailability:(int) availability;
+(UserMarker*) getMarker:(NSString*)type;

+(int) getSelectedMarker;
+(void) setSelectedMarker: (int) marker;
+(void) changeCurrentVenue: (int) index;

- (void) getVenueLocations:(NSString*)friendId;
+(void) removeMarker;

+(void)setDelegate:(EventViewController*)controllerDelegate;
@end
