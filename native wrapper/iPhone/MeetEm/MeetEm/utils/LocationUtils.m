//
//  LocationUtils.m
//  MeetEm
//
//  Created by Paul Schmidt on 16.02.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "LocationUtils.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@implementation LocationUtils

static id delegate;

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

+ (NSString*) formatDistance: (CLLocationCoordinate2D)geoPoint
{
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    
    
    CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    CLLocationDistance distance = [[manager location] distanceFromLocation:venueLocation];
    
    
    int timePerKM;
    if(distance > 1500) {
        timePerKM = 3; // TODO: 3min per kilometer. Works in Berlin. Make better!
    } else {
        timePerKM = 10; // TODO: 10m per kilometer walking speed
    }
    int time = distance/1000 * timePerKM;
    
    NSString* formattedDistance = @"";
    if(distance >= 1000)
    {
        distance = round(distance/1000);
        formattedDistance = [NSString stringWithFormat:@"%.f km", distance];
    }
    else
    {
        formattedDistance = [NSString stringWithFormat:@"%.f m", distance];
    }
    
    formattedDistance = [formattedDistance stringByAppendingString:@", "];
    formattedDistance = [formattedDistance stringByAppendingString:[NSString stringWithFormat:@"%i min", time]];
    
    return formattedDistance;
}

+(void) setDelegate:(id)locationUtilsDelegate
{
    delegate = locationUtilsDelegate;
}


+(void) getVenueForFriend:(NSString*)friend;
{
    [PFCloud callFunctionInBackground:@"getVenues"
                       withParameters:@{@"friendIds" : friend}
                                block:^(NSObject *result, NSError *error)
     {
         [delegate bestVenueDataReceived:result withType:@""];
         
     }];
    
    /*
    NSLog(@"getVenueForLocation type:%@, radius:%i", type, radius);
    __block int blockRadius = radius;
    NSString* foursquareCall = @"https://api.foursquare.com/v2/venues/search";
    foursquareCall = [foursquareCall stringByAppendingString:@"?ll="];
    foursquareCall = [foursquareCall stringByAppendingString:[NSString stringWithFormat:@"%f", location.latitude]];
    foursquareCall = [foursquareCall stringByAppendingString:@","];
    foursquareCall = [foursquareCall stringByAppendingString:[NSString stringWithFormat:@"%f", location.longitude]];
    foursquareCall = [foursquareCall stringByAppendingString:@"&radius="];
    foursquareCall = [foursquareCall stringByAppendingString:[NSString stringWithFormat:@"%i", radius]];
    foursquareCall = [foursquareCall stringByAppendingString:@"&categoryId="];
    foursquareCall = [foursquareCall stringByAppendingString:@"4bf58dd8d48988d116941735"];
    foursquareCall = [foursquareCall stringByAppendingString:@"&intent=browse&oauth_token="];
    foursquareCall = [foursquareCall stringByAppendingString:@"B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV&v=20130811"];
    NSURL *url = [[NSURL alloc] initWithString:foursquareCall];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        NSDictionary *dict = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:nil];
        if (!dict)
        {
            NSLog(@"No Data found for %@", type);
            NSString* foursquareData = [NSString stringWithUTF8String:[data bytes]];
            if (foursquareData)
            {
                if ([foursquareData rangeOfString:@"Error"].location != NSNotFound)
                {
                    NSLog(@"Error appeared: \n%@", foursquareData);
                    [delegate foursquareNotReached];
                    return;
                }
            }
            else
            {
                blockRadius = blockRadius * 2;
                [LocationUtils getVenueForLocation:location withType:type withRadius:blockRadius];
                return;
            }
        }
        
        int highestCheckin = 0;
        NSMutableDictionary* bestVenue;
        NSDictionary* venues = [[dict valueForKey:@"response"] valueForKey:@"venues"];
        for (NSMutableDictionary* venue in venues)
        {
            if(highestCheckin < [[[venue valueForKey:@"stats"] valueForKey:@"checkinsCount"] integerValue])
            {
                bestVenue = [venue mutableCopy];
                highestCheckin = [[[venue valueForKey:@"stats"] valueForKey:@"checkinsCount"] integerValue];
            }
        }
        
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        CLLocationDegrees lat = [[[bestVenue valueForKey:@"location"] valueForKey:@"lat"] doubleValue];
        CLLocationDegrees lon = [[[bestVenue valueForKey:@"location"] valueForKey:@"lng"] doubleValue];
        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        CLLocationDistance distance = [[manager location] distanceFromLocation:venueLocation];
        [bestVenue setValue:[NSNumber numberWithDouble:distance] forKey:@"distanceToMe"];
        if(bestVenue)
        {
            [delegate bestVenueDataReceived:bestVenue withType:type];
        }
        else
        {
            blockRadius = blockRadius * 2;
            [LocationUtils getVenueForLocation:location withType:type withRadius:blockRadius];
        }
    }];*/
}

@end
