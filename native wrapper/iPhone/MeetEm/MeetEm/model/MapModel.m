//
//  MapModel.m
//  MeetEm
//
//  Created by Paul Schmidt on 09.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "MapModel.h"
#import "UserMarker.h"

#import "LocationUtils.h"

@implementation MapModel

static MKMapView* map;
static UserMarker* annotation;

static NSDictionary* currentVenue;

static NSMutableArray* mapPins;

static int selectedMarker = 0;

+ (void)showMap
{
    if(map)
    {
        [map setHidden:NO];
    }
}

+(NSDictionary*) getCurrentVenue
{
    return currentVenue;
}

+(void) changeCurrentVenue: (int) index
{
    currentVenue = venues[index];
}

+(int) getSelectedMarker
{
    return selectedMarker;
}
+(void) setSelectedMarker: (int) marker
{
    selectedMarker = marker;
}

+(void) removeMarker
{
    [map removeAnnotations:mapPins];
}

+ (void)hideMap
{
    if(map)
    {
        venues = [[NSMutableArray alloc] init];
        mapPins = [[NSMutableArray alloc] init];
        [map setHidden:YES];
    }
}

+ (void)setMapView:(MKMapView*) mapView
{
    
    map = mapView;
    [map showsUserLocation];
}

/*
 Adds Marker for the selected friend
 */
+ (void)addMarker:(CLLocationDegrees)lat atLongitude:(CLLocationDegrees)lon forFriend:(NSString*)friend withAvailability:(int) availability
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
    UserMarker *pin = [[UserMarker alloc] initWithCoordinates:location userID:friend availability:availability];
    
    if(!mapPins)
    {
        mapPins = [[NSMutableArray alloc] init];
    }
    
    [mapPins addObject:pin];
    if(map)
        [map addAnnotation:pin];
}

/*
 Adds Marker for the current user
 */
+ (void)addMarker:(NSString*)me withAvailability:(int) availability
{
    if(!mapPins)
    {
        mapPins = [[NSMutableArray alloc] init];
    }
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    CLLocationCoordinate2D userLocation = manager.location.coordinate;
    
    UserMarker *pin = [[UserMarker alloc] initWithCoordinates:userLocation userID:me availability:availability];
    [mapPins addObject:pin];
    if(map)
        [map addAnnotation:pin];
}

+ (void)addMarker:(CLLocationDegrees)lat atLongitude:(CLLocationDegrees)lon
{
    if(!mapPins)
    {
        mapPins = [[NSMutableArray alloc] init];
        
        
    }
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(lat, lon);
    
    UserMarker *pin = [[UserMarker alloc] initWithCoordinates:location userID:@"mine" availability:0];
    [mapPins addObject:pin];
    if(map)
        [map addAnnotation:pin];
}



static EventViewController* delegate;

+(void) setDelegate:(EventViewController *)controllerDelegate
{
    delegate = controllerDelegate;
}

+(UserMarker*) getMarker:(NSString*)type
{
    UserMarker* marker = [currentVenue valueForKey:@"marker"];
    return marker;
}

NSMutableArray* venues;

- (void) getVenueLocations:(NSString*)friendId
{
    if(venues == nil)
        venues = [[NSMutableArray alloc] init];
    [venues removeAllObjects];
    
    if(!mapPins)
    {
        mapPins = [[NSMutableArray alloc] init];
    }
    else
    {
        [mapPins removeAllObjects];
    }
    
    [LocationUtils setDelegate:self];
    
    [LocationUtils getVenueForFriend: friendId];
}

-(void) foursquareNotReached
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Foursquare not reached" message:@"Sorry, we have problems reaching the foursquare server" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //[alertView show];
}

-(void) bestVenueDataReceived:(NSArray *)venue withType:(NSString *)type
{
    venues = [venue mutableCopy];
    
    
    currentVenue = venues[0];
    if (map)
    {
        UserMarker *pin;
        
        for (int i = 0; i < venues.count; ++i)
        {
            CLLocationDegrees lat = [[[[venues[i] valueForKey:@"venue"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue];
            CLLocationDegrees lon = [[[[venues[i] valueForKey:@"venue"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue];
            CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                
            pin = [[UserMarker alloc] initWithCoordinates:venueLocation.coordinate userID:[venues[i] valueForKey:@"type"] availability:0];
            pin.index = i;
            [map addAnnotation:pin];
            [venues[i] setValue:pin forKey:@"marker"];
            [delegate venueDataReceived:venues[i]];
        }
    }
    
}



@end
