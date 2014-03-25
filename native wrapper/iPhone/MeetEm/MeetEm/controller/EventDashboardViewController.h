//
//  EventDashboardViewController.h
//  MeetEm
//
//  Created by Paul Schmidt on 01.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "EventVO.h"
#import "EventAttendeeVO.h"

@interface EventDashboardViewController : UIViewController<MKMapViewDelegate, UIAlertViewDelegate>

typedef NS_ENUM(NSInteger, EventDashboardState)
{
    EventDashboardStatePending,
    EventDashboardStateAccept,
    EventDashboardStateNormal,
    EventDashboardStateResettime
};


@property (retain, nonatomic) EventVO* event;
@property (nonatomic) BOOL isPending;
@property (nonatomic) EventDashboardState dashboardState;

- (void)refreshView;

@end
