//
//  MapModel.h
//  MeetEm
//
//  Created by Paul Schmidt on 09.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapModel : NSObject<MKMapViewDelegate>
+ (void)showMap;
+ (void)hideMap;
+ (void)setMapView:(MKMapView*) mapView;
+ (void)addMarker:(NSString*) mapObj;
@end
