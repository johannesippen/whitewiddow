//
//  LocationController.h
//  Whitewidow
//
//  Created by Paul Schmidt on 13.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface LocationController : NSObject<CLLocationManagerDelegate>
- (void) authorize;
- (NSData*) getAuthorizationState;
- (void) saveCurrentLocation;
- (void) getLocation;
- (void) registerForRegion:(CLLocationCoordinate2D)coord withRadius:(CLLocationDistance)radius withIdentifier:(NSString*) identifier;
- (void) unregisterForRegion:(CLLocationCoordinate2D)coord withRadius:(CLLocationDistance)radius withIdentifier:(NSString*) identifier;
-(void) setCallback:(id)object withSelector:(SEL)selector andIdentifier:(NSString*) identifier;
@end
