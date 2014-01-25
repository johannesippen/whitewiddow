//
//  EventViewController.m
//  MeetEm
//
//  Created by Paul Schmidt on 19.01.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "EventViewController.h"
#import "MapModel.h"

@interface EventViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation EventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MapModel setMapView:self.mapView];
    
	// Do any additional setup after loading the view.
}


-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // this part is boilerplate code used to create or reuse a pin annotation
    static NSString *viewId = @"MKPinAnnotationView";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)
    [mapView dequeueReusableAnnotationViewWithIdentifier:viewId];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc]
                          initWithAnnotation:annotation reuseIdentifier:viewId];
    }
    // set your custom image
    annotationView.image = [UIImage imageNamed:@"icon-cocktail.png"];
    return annotationView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
