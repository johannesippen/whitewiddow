//
//  EventViewController.h
//  MeetEm
//
//  Created by Paul Schmidt on 19.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "UserMarker.h"
#import "EventViewControllerDelegate.h"

@interface EventViewController : UIViewController<MKMapViewDelegate, NSURLConnectionDelegate, UIScrollViewDelegate, EventViewControllerDelegate>


@property (nonatomic, retain) NSString* facebookID;
//@property (nonatomic, retain) UIPageControl * pageControl;

-(void) updateLocationLabel:(NSString*)location withDistance: (CLLocationDistance) distance withDescription:description;
-(void) selectMarker: (int)index;


@end
