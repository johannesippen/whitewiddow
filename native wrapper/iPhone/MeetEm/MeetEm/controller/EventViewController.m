//
//  EventViewController.m
//  MeetEm
//
//  Created by Paul Schmidt on 19.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "EventViewController.h"
#import "MapModel.h"
#import <Parse/Parse.h>
#import "EventModel.h"
#import "UserMarker.h"
#import "SocialModel.h"
#import "LocationView.h"
#import "EventDashboardViewController.h"
#import "UserAnnotationView.h"
#import "VenueAnnotationView.h"

@interface EventViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *naviBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;


@end

@implementation EventViewController

@synthesize facebookID;
//@synthesize pageControl=pageControl_;

BOOL canResetMarker = YES;

PFObject* currentFriend;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)_sendInvite:(id)sender
{
    [EventModel createEvent:[[MapModel getCurrentVenue] valueForKey:@"venue"] withAttendee:facebookID];
}

-(void) eventSaved
{
    [PFCloud callFunctionInBackground:@"getEventState"
                       withParameters:@{}
                                block:^(NSObject *result, NSError *error)
     {
         if (!error)
         {
             int statusCode = [[result valueForKey:@"statusCode"] integerValue];
             if(statusCode == EventStatePending)
             {
                 UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                 EventDashboardViewController* viewCtrl = (EventDashboardViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"EventDashboardView"];
                 viewCtrl.dashboardState = EventDashboardStatePending;
                 viewCtrl.event = [result valueForKey:@"event"];
                 if(![self.navigationController.viewControllers[self.navigationController.viewControllers.count - 1] isKindOfClass:[EventDashboardViewController class]])
                 {
                     [self.navigationController pushViewController: viewCtrl animated:NO];
                 }
             }
         }
     }];
}

-(void) venueDataReceived:(NSDictionary*) venues
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        LocationView* locationView = [[LocationView alloc] initWithFrame:CGRectMake(0, -25, 320, 97)];
        
        locationView.frame = CGRectMake(([self.scrollView subviews].count)*320 , locationView.frame.origin.y, locationView.frame.size.width, locationView.frame.size.height);
        
        NSLog(@"Count: %i", [self.scrollView subviews].count);
        
        
        [self.scrollView addSubview:locationView];
        self.scrollView.contentSize = CGSizeMake(320*[self.scrollView subviews].count, 97);
        
        
        [locationView updateDistance:[self formatDistance: [[[venues valueForKey:@"venue"] valueForKey:@"distanceToMe"] doubleValue]]];
        [locationView updateLocation:[[venues valueForKey:@"venue"] valueForKey:@"name"]];
        [locationView updateDescription:[venues valueForKey:@"type"]];
        [self.mapView showAnnotations:[self.mapView annotations] animated:YES];
        
        
        NSString* headline = @"Meet ";
        headline = [headline stringByAppendingString:[currentFriend valueForKey:@"facebookName"]];
        [self.navigationItem setTitle:headline];
        
        // Select the current Annotation
        [self.mapView selectAnnotation:[MapModel getMarker:@""] animated:YES];
        
        // Gets the location of the current user
        self.pageControl.numberOfPages = [self.scrollView subviews].count;
        if (self.pageControl.numberOfPages == 1) {
            [self.pageControl setHidden:YES];
        }
        else
        {
            [self.pageControl setHidden:NO];
        }
    });
    
}

-(void) selectMarker: (int)index
{
    [self.mapView selectAnnotation:[MapModel getMarker:@""] animated:YES];
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKPinAnnotationView *)view {
    
    if(canResetMarker)
    {
        canResetMarker = NO;
        
        [view setSelected:YES];
    
        UserMarker*marker = view.annotation;
        NSLog(@"Select %i", marker.index);
    
        [MapModel setSelectedMarker:marker.index];
    
    
    
        if(marker.index != -1)
        {
            [self.scrollView setContentOffset:CGPointMake(marker.index*320, 0) animated:YES];
        }
        NSTimer *timer;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(resetMarker) userInfo:nil repeats:NO];
        [timer fire];
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [view setSelected:NO];
}

-(void)resetMarker
{
    NSLog(@"resetMarker");
    canResetMarker = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = 320;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if(page != self.pageControl.currentPage)
    {
        [MapModel changeCurrentVenue:page];
        [self selectMarker:self.pageControl.currentPage];
    }
    self.pageControl.currentPage = page;
}

- (NSString*) formatDistance: (CLLocationDistance)distance
{
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
    return formattedDistance;
}

- (void)_loadUserdata
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:facebookID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFGeoPoint *geoCoord = object[@"lastLocation"];
        currentFriend = object;
        MapModel *model = [[MapModel alloc] init];
        [model getVenueLocations:object.objectId];
        int availability = [[object valueForKey:@"currentAvailability"] intValue];
        NSDate* lastAvailability = [object valueForKey:@"lastAvailability"];
        [MapModel addMarker:geoCoord.latitude atLongitude:geoCoord.longitude forFriend:object[@"fbId"] withAvailability:[SocialModel getCurrentAvailabilityFromUser:availability withDate: lastAvailability]];
    }];
    
    PFUser *user = [PFUser currentUser];
    [MapModel addMarker:[user valueForKey:@"fbId"] withAvailability:[SocialModel getCurrentAvailabilityFromUser: [[user valueForKey:@"currentAvailability"] intValue] withDate:[user valueForKey:@"lastAvailability"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [MapModel setMapView:self.mapView];
    [EventModel setDelegate:self];
    
    [MapModel setDelegate:self];
    [self.navigationController setNavigationBarHidden:NO];
    //[self.navigationItem setTitle:@"Meet him at the midpoint"];
    
	// Do any additional setup after loading the view.
    [self _loadUserdata];
    
    self.scrollView.delegate = self;
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
    [self.view addSubview:self.pageControl];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}



-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // this part is boilerplate code used to create or reuse a pin annotation
    static NSString *viewId = @"MKPinAnnotationView";
    // set your custom image
    
    NSLog(@"Title: %@", [annotation title]);
    if((![[annotation title] isEqualToString:@"Current Location"]) && (![[annotation title] isEqualToString:@"middle"] && ![[annotation title] isEqualToString:@"mine"] && ![[annotation title] isEqualToString:@"friend"]))
    {
        UserAnnotationView *annotationView = (UserAnnotationView*)
        [mapView dequeueReusableAnnotationViewWithIdentifier:@"UserAnnotationView"];
        if (annotationView == nil) {
            annotationView = [[UserAnnotationView alloc]
                              initWithAnnotation:annotation reuseIdentifier:@"UserAnnotationView"];
        }
        annotationView.centerOffset = CGPointMake(0,0);
        annotationView.calloutOffset = CGPointMake(0,0);
        return annotationView;
    }
    else
    {
        VenueAnnotationView *annotationView = (VenueAnnotationView*)
        [mapView dequeueReusableAnnotationViewWithIdentifier:viewId];
        if (annotationView == nil) {
            annotationView = [[VenueAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewId];
        }
        
        annotationView.centerOffset = CGPointMake(0,0);
        annotationView.calloutOffset = CGPointMake(0,0);
        return annotationView;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
