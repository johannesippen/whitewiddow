//
//  LocationController.m
//  Whitewidow
//
//  Created by Paul Schmidt on 13.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "LocationController.h"
#import <Parse/Parse.h>
#import "UIWebviewInterfaceController.h"
#import "JSONHelper.h"
#import "Logger.h"
#import "TestFlight.h"
#import "FunctionTestViewController.h"

@interface LocationController ()
@property (nonatomic)  CLLocationManager *manager;
@end

@implementation LocationController
NSMutableDictionary* callBacks;

- (CLLocationManager*) manager
{
    if(_manager == nil)
    {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        callBacks = [[NSMutableDictionary alloc] init];
    }
    return _manager;
}


-(void) registerForRegion:(CLLocationCoordinate2D)coord withRadius:(CLLocationDistance)radius withIdentifier:(NSString*)identifier
{
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:radius identifier:identifier];
    
    [self.manager startMonitoringForRegion:region];
    
    NSSet *regions = [self.manager monitoredRegions];
    
}

-(void) unregisterForRegion:(CLLocationCoordinate2D)coord withRadius:(CLLocationDistance)radius withIdentifier:(NSString*) identifier
{
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coord radius:radius identifier:identifier];
    
    [self.manager stopMonitoringForRegion:region];
}

- (void) authorize
{
    [self.manager startUpdatingLocation];
    [Logger logMessage:@"authorize for Location" withScope:@"Location"];
}

- (void) saveCurrentLocation
{
    if([PFUser currentUser] != nil)
    {
        PFObject* currentLocation = [PFObject objectWithClassName:@"UserLocation"];
        
        
        [self getAuthorizationState];
        NSLog(@"state: %i", [CLLocationManager authorizationStatus]);
        
        
        CLLocation* location = [self.manager location];
        if(location)
        {
            CLLocationCoordinate2D coord = [location coordinate];
            
            
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coord.latitude longitude:coord.longitude];
            [currentLocation setObject:[PFUser currentUser] forKey:@"user"];
            [currentLocation setObject:geoPoint forKey:@"location"];
            
            
            [currentLocation saveEventually];
        
            PFUser* lastLocation = [PFUser currentUser];
            [lastLocation setValue:geoPoint forKey:@"lastLocation"];
            [lastLocation saveEventually];
        }
    }
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    PFObject* currentLocation = [PFObject objectWithClassName:@"UserLocation"];
    CLLocation* location = [manager location];
    CLLocationCoordinate2D coord = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coord.latitude longitude:coord.longitude];
    [currentLocation setObject:[PFUser currentUser] forKey:@"user"];
    [currentLocation setObject:geoPoint forKey:@"location"];
    [currentLocation saveEventually];
    
    PFUser* lastLocation = [PFUser currentUser];
    [lastLocation setValue:geoPoint forKey:@"lastLocation"];
    [lastLocation saveEventually];

}

-(void) setCallback:(id)object withSelector:(SEL)selector andIdentifier:(NSString*) identifier
{
    NSDictionary *selectorSet = [[NSMutableDictionary alloc]init];
    [selectorSet setValue:object forKey:@"object"];
    [selectorSet setValue:NSStringFromSelector(selector) forKey:@"selector"];
    [callBacks setObject:selectorSet forKey:identifier];
}

- (void) getLocation
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    CLLocation* location = [self.manager location];
    CLLocationCoordinate2D coord = [location coordinate];
    [dict setValue:[NSNumber numberWithDouble:coord.latitude] forKey:@"latitude"];
    [dict setValue:[NSNumber numberWithDouble:coord.longitude] forKey:@"longitude"];
    [dict setValue:[NSNumber numberWithDouble:location.altitude] forKey:@"altitude"];
    [dict setValue:[NSNumber numberWithDouble:location.speed] forKey:@"speed"];
    [dict setValue:[NSNumber numberWithDouble:location.course] forKey:@"course"];
    [dict setValue:[NSNumber numberWithDouble:location.horizontalAccuracy] forKey:@"horizontalAccuracy"];
    [dict setValue:[NSNumber numberWithDouble:location.verticalAccuracy] forKey:@"verticalAccuracy"];
    [Logger logMessage:@"getLocation" withScope:@"Location"];
    [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"getLocation"]];
    if([callBacks objectForKey:@"getLocation"] != nil)
    {
        id locationObject = [[callBacks valueForKey:@"getLocation"] valueForKey:@"object"];
        SEL locationSelector = NSSelectorFromString([[callBacks valueForKey:@"authorizationState"] valueForKey:@"selector"]);
        [locationObject performSelector:locationSelector withObject:@"getLocation"];
    }
}

- (NSData*) getAuthorizationState
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorized:
            [dict setValue:@"authorized" forKey:@"authorizationState"];
            [Logger logMessage:@"authorized" withScope:@"Location"];
            break;
            
        case kCLAuthorizationStatusDenied:
            [dict setValue:@"denied" forKey:@"authorizationState"];
            [Logger logMessage:@"denied" withScope:@"Location"];
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            [dict setValue:@"notDetermined" forKey:@"authorizationState"];
            [Logger logMessage:@"not determined" withScope:@"Location"];
            break;
            
        case kCLAuthorizationStatusRestricted:
            [dict setValue:@"restricted" forKey:@"authorizationState"];
            [Logger logMessage:@"restricted" withScope:@"Location"];
            break;
    }
    [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"getCoreLocationAuthorizeState"]];
    return [JSONHelper convertDictionaryToJSON:dict forSignal:@"getCoreLocationAuthorizeState"];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Locationerror!!!!");
}

-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
            [dict setValue:@"authorized" forKey:@"authorizationState"];
            [Logger logMessage:@"authorized" withScope:@"Location"];
            [TestFlight passCheckpoint:@"Locationbasedservice authorized"];
            break;
            
        case kCLAuthorizationStatusDenied:
            [dict setValue:@"denied" forKey:@"authorizationState"];
            [Logger logMessage:@"denied" withScope:@"Location"];
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            [dict setValue:@"notDetermined" forKey:@"authorizationState"];
            [Logger logMessage:@"not determined" withScope:@"Location"];
            break;
            
        case kCLAuthorizationStatusRestricted:
            [dict setValue:@"restricted" forKey:@"authorizationState"];
            [Logger logMessage:@"restricted" withScope:@"Location"];
            break;
    }
    [UIWebviewInterfaceController callJavascript:[JSONHelper convertDictionaryToJSON:dict forSignal:@"getCoreLocationAuthorizeState"]];
    if([callBacks objectForKey:@"authorizationState"] != nil)
    {
        id locationObject = [[callBacks valueForKey:@"authorizationState"] valueForKey:@"object"];
        SEL locationSelector = NSSelectorFromString([[callBacks valueForKey:@"authorizationState"] valueForKey:@"selector"]);
        [locationObject performSelector:locationSelector withObject:@"authorizationState"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            // result is a dictionary with the user's Facebook data
            NSMutableDictionary *userData = (NSMutableDictionary *)result;
            
            NSString *username = userData[@"name"];
            NSString *pushMessage = [username stringByAppendingString:@" ist bei mein Haus am See angekommen."];
            
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:region.identifier];
            [push setMessage:pushMessage];
            [push sendPushInBackground];
            for (CLRegion *localRegion in [manager monitoredRegions])
            {
                if ([localRegion.identifier isEqual:region.identifier]) {
                    
                    [manager stopMonitoringForRegion:localRegion];
                }
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
}
@end
