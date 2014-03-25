//
//  EventDashboardViewController.m
//  MeetEm
//
//  Created by Paul Schmidt on 01.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "EventDashboardViewController.h"
#import "EventModel.h"
#import "LocationUtils.h"
#import "UserMarker.h"
#import "MapModel.h"
#import "SocialModel.h"
#import "PushController.h"
#import "UserAnnotationView.h"
#import "VenueAnnotationView.h"

@interface EventDashboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *changetimeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *addFriendsButton;
@property (weak, nonatomic) IBOutlet UIImageView *clockImage;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation EventDashboardViewController
@synthesize event;

BOOL timerIsRunning = NO;

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
    self.mapView.delegate = self;
    [MapModel setMapView:self.mapView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headlineLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:18]];
        
        [self.locationLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:18]];
        [self.descriptionLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:14]];
        [self.distanceLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:14]];
        [self.timeLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:18]];
        [self.countdownLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:14]];
        [self.changetimeLabel setFont: [UIFont fontWithName:@"MissionGothic-Regular" size:14]];
        [self.addFriendsButton.titleLabel setFont:[UIFont fontWithName:@"MissionGothic-Regular" size:25]];
        
        switch (_dashboardState)
        {
            case EventDashboardStatePending:
                self.countdownLabel.text = @"wait for your";
                self.timeLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
                self.changetimeLabel.textColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
                self.changetimeLabel.text = @" friends suggestion";
                self.headlineLabel.text = @"Your request is pending...";
                self.headlineLabel.textColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
                self.clockImage.image = [UIImage imageNamed:@"icon-clock-gray"];
                [self.addFriendsButton setBackgroundImage: [UIImage imageNamed:@"Add-Friends-Button-2x"] forState:UIControlStateNormal];
                [self.addFriendsButton setTitleColor: [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1] forState:UIControlStateNormal];
                self.addFriendsButton.titleLabel.text = @"Add more Friends";
                [self.leftButton setBackgroundImage:[UIImage imageNamed:@"Cancel-Button-2x"] forState:UIControlStateNormal];
                break;
                
            case EventDashboardStateAccept:
                self.countdownLabel.text = @"wait for your";
                self.timeLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
                self.changetimeLabel.textColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
                self.changetimeLabel.text = @"suggestion";
                
                // TODO: dynamic Text
                self.headlineLabel.text = @"Nico invites you, dude!";
                self.headlineLabel.textColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
                self.clockImage.image = [UIImage imageNamed:@"icon-clock-gray"];
                [self.addFriendsButton setBackgroundImage: [UIImage imageNamed:@"Set-Time-Accept-Button-2x"] forState:UIControlStateNormal];
                [self.addFriendsButton setTintColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
                [self.addFriendsButton setTitleColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
                
                [self.addFriendsButton setTitle:@"Set Time & Accept" forState:UIControlStateNormal];
                [self.leftButton setBackgroundImage:[UIImage imageNamed:@"Deny-Button-2x"] forState:UIControlStateNormal];
                break;
                
            default:
                self.countdownLabel.text = @"";
                self.changetimeLabel.text = @"Change Time";
                self.changetimeLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
                self.headlineLabel.text = @"Let's get ready to rumble!";
                self.headlineLabel.textColor = [UIColor colorWithRed:.0 green:.54 blue:1 alpha:1];
                self.timeLabel.textColor = [UIColor colorWithRed:.0 green:.54 blue:1 alpha:1];
                self.clockImage.image = [UIImage imageNamed:@"icon-clock-blue"];
                [self.addFriendsButton setBackgroundImage: [UIImage imageNamed:@"Add-Friends-Button-2x"] forState:UIControlStateNormal];
                [self.addFriendsButton setTitleColor: [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1] forState:UIControlStateNormal];
                self.addFriendsButton.titleLabel.text = @"Add more Friends";
                [self.leftButton setBackgroundImage:[UIImage imageNamed:@"Cancel-Button-2x"] forState:UIControlStateNormal];
                break;
        }
    });
    
    if(event)
        [self refreshView];
    if(_dashboardState != EventDashboardStatePending && _dashboardState != EventDashboardStateAccept)
    {
        timerIsRunning = NO;
        [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
    }
	
}
- (IBAction)onDeleteButtonPressed:(id)sender
{
    UIAlertView *alertView;
    NSString* alertMessage;
    switch (_dashboardState)
    {
        case EventDashboardStateAccept:
            alertMessage = @"Are you sure you don't wanna meet ";
            alertMessage = [alertMessage stringByAppendingString:event.friend.facebookName];
            alertMessage = [alertMessage stringByAppendingString:@"?"];
            alertView = [[UIAlertView alloc] initWithTitle:@"Deny Invitation" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            break;
            
        case EventDashboardStateNormal:
            alertMessage = @"Are you sure you don't wanna meet ";
            alertMessage = [alertMessage stringByAppendingString:event.friend.facebookName];
            alertMessage = [alertMessage stringByAppendingString:@"?"];
            alertView = [[UIAlertView alloc] initWithTitle:@"Cancel Event" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            break;
        
        case EventDashboardStatePending:
            alertMessage = @"Are you sure you don't wanna meet ";
            
            alertMessage = [alertMessage stringByAppendingString:event.friend.facebookName];
            alertMessage = [alertMessage stringByAppendingString:@"?"];
            alertView = [[UIAlertView alloc] initWithTitle:@"Cancel Event" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            break;
            
        default:
            break;
    }
    
    [alertView show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSArray *attendees = [event valueForKey:@"attendees"];
        for (int i = 0; i < attendees.count; ++i)
        {
            [attendees[i] setValue:[NSNumber numberWithInt:3] forKey:@"invitationState"];
        }
        [PFObject saveAllInBackground:attendees];
        
        NSString *channelID = @"friend_";
        channelID = [channelID stringByAppendingString:event.friend.fbId];
        PFPush *push = [[PFPush alloc] init];
        [push setChannel:channelID];
        NSString* pushMessage = event.currentUser.facebookName;
        if(_dashboardState == EventDashboardStateAccept)
        {
            pushMessage = [pushMessage stringByAppendingString:@" denied your invitation."];
        }
        else{
            pushMessage = [pushMessage stringByAppendingString:@" canceled the event."];
        }
        
        [push setMessage:pushMessage];
        [push sendPushInBackground];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)onAddFriendsClicked:(id)sender
{
 
    if(_dashboardState == EventDashboardStateAccept)
    {
        [self.timeView setHidden:NO];
    }
    else{
        NSString* alertMessage = @"We hustle hard to bring you this feature in one of the next updates.";
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Coming soon!" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)changeToDashboard
{
    self.countdownLabel.text = @"";
    self.changetimeLabel.text = @"Change Time";
    self.changetimeLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
    self.headlineLabel.text = @"Let's get ready to rumble!";
    self.headlineLabel.textColor = [UIColor colorWithRed:.0 green:.54 blue:1 alpha:1];
    self.timeLabel.textColor = [UIColor colorWithRed:.0 green:.54 blue:1 alpha:1];
    self.clockImage.image = [UIImage imageNamed:@"icon-clock-blue"];
    [self.addFriendsButton setBackgroundImage: [UIImage imageNamed:@"Add-Friends-Button-2x"] forState:UIControlStateNormal];
    [self.addFriendsButton setTitleColor: [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1] forState:UIControlStateNormal];
    self.addFriendsButton.titleLabel.text = @"Add more Friends";
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"Cancel-Button-2x"] forState:UIControlStateNormal];
}

- (void)refreshView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationLabel.text = event.venueName;
        self.distanceLabel.text = [LocationUtils formatDistance:event.location];
        
        if(_dashboardState == EventDashboardStatePending || _dashboardState == EventDashboardStateAccept)
        {
            self.timeLabel.text = @"XX:XX";
        }
        else
        {
            NSDateFormatter *inFormat = [[NSDateFormatter alloc] init];
            [inFormat setDateFormat:@"HH:mm"];
            self.timeLabel.text = [inFormat stringFromDate:event.eventDate];
            if(!timerIsRunning)
            {
                [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(tick:)
                                           userInfo:nil
                                            repeats:YES];
                timerIsRunning = NO;
            }
        }
        
        if(_dashboardState == EventDashboardStateNormal)
        {
            [self changeToDashboard];
        }
        
        // Sets Headline of the screen
        if(_dashboardState == EventDashboardStateAccept && event.organisator)
        {
            NSString *headlineText = @"";
            headlineText = event.organisator.facebookName;
            headlineText = [headlineText stringByAppendingString:@" invites you, dude!"];
            self.headlineLabel.text = headlineText;
        }
        
        [MapModel removeMarker];
        
        // Add Marker for me
        [MapModel addMarker:event.currentUser.fbId withAvailability:[SocialModel getCurrentAvailabilityFromUser:event.currentUser.availability withDate:event.currentUser.lastAvailability]];
        
        // Add Marker for friend
        [MapModel addMarker:event.location.latitude atLongitude:event.location.longitude forFriend:event.friend.fbId withAvailability:[SocialModel getCurrentAvailabilityFromUser:event.friend.availability withDate:event.friend.lastAvailability]];
        
        // Add Marker for location
        [MapModel addMarker:event.location.latitude atLongitude:event.location.longitude];
        
        [self.mapView showAnnotations:[self.mapView annotations] animated:YES];
    });
}

- (void) tick:(NSTimer *) timer {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* timeUntilEvent = @"in ";
        NSDate *now = [NSDate date];
        NSDate *eventTime = [event valueForKey:@"eventDate"];
        NSTimeInterval interval = [eventTime timeIntervalSinceDate:now];
        int hours = abs(floorf(interval/60/60));
        int minutes = abs(fmodf(floorf(interval / 60), 60));
        int seconds = abs(fmodf(interval, 60));
        
        if(interval < 0)
        {
            timeUntilEvent = [timeUntilEvent stringByAppendingString:[NSString stringWithFormat:@"-%i", hours]];
        }
        else
        {
            timeUntilEvent = [timeUntilEvent stringByAppendingString:[NSString stringWithFormat:@"%i", hours]];
        }
        
        timeUntilEvent = [timeUntilEvent stringByAppendingString:@":"];
        if(minutes < 10)
        {
            timeUntilEvent = [timeUntilEvent stringByAppendingString:[NSString stringWithFormat:@"0%i", minutes]];
        }
        else
        {
            timeUntilEvent = [timeUntilEvent stringByAppendingString:[NSString stringWithFormat:@"%i", minutes]];
        }
        
        timeUntilEvent = [timeUntilEvent stringByAppendingString:@":"];
        if(seconds < 10)
        {
            timeUntilEvent = [timeUntilEvent stringByAppendingString:[NSString stringWithFormat:@"0%i", seconds]];
        }
        else
        {
            timeUntilEvent = [timeUntilEvent stringByAppendingString:[NSString stringWithFormat:@"%i", seconds]];
        }
        timeUntilEvent = [timeUntilEvent stringByAppendingString:@" h"];
        self.countdownLabel.text = timeUntilEvent;
    });
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

- (IBAction)onCancelButtonPressed:(id)sender{
     [self.timeView setHidden:YES];
}
- (IBAction)onDoneButtonPressed:(id)sender
{
    [event.currentUser.object setObject:[NSNumber numberWithInt:2] forKey:@"invitationState"];
    [event.currentUser.object saveEventually];
    
    [event.object setValue:[self.timePicker date] forKey:@"eventDate"];
    [event.object saveEventually:^(BOOL succeeded, NSError *error)
     {
         NSString *channelID = @"event_";
         channelID = [channelID stringByAppendingString:[event valueForKey:@"objectId"]];
         
         [PushController registerPushForEvent:[event valueForKey:@"objectId"]];
         
         PFPush *push = [[PFPush alloc] init];
         [push setChannel:channelID];
         NSString* pushMessage = event.currentUser.facebookName;
         pushMessage = [pushMessage stringByAppendingString:@" accepts your invitation."];
         [push setMessage:pushMessage];
         [push sendPushInBackground];
         
         NSString* alertMessage = @"Please be on time, otherwise ";
         alertMessage = [alertMessage stringByAppendingString:event.friend.facebookName];
         alertMessage = [alertMessage stringByAppendingString:@" just might kick your ass."];
         UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"We have a deal!" message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         
         [alertView show];
         
         self.timeView.hidden = YES;
         
         UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
         EventDashboardViewController* viewCtrl = (EventDashboardViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"EventDashboardView"];
         viewCtrl.dashboardState = EventDashboardStateNormal;
         viewCtrl.event = event;
         [self.navigationController pushViewController: viewCtrl animated:NO];
     }];

}



@end
