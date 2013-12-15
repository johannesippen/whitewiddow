//
//  ViewController.m
//  Whitewidow
//
//  Created by Paul Schmidt on 11.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <Accounts/Accounts.h>
#import "LocationController.h"
#import "ContactsModel.h"
#import "UIWebviewInterfaceController.h"
#import "SocialModel.h"
#import "Logger.h"
#import "EventModel.h"
#import "FunctionTestViewController.h"

@interface ViewController ()
@property IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextView *debugView;
@property LocationController *locationCtrl;
@property (weak, nonatomic) IBOutlet UITableView *featureSelectionTable;
@property BOOL isDebugger;
@end

@implementation ViewController
- (IBAction)_onButtonPressed:(UIButton *)sender
{
    [EventModel createEvent:@"&data={\"latitude\":\"12\", \"longitude\":\"52\", \"title\":\"Mein Haus am See\"}"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://thxalot.dermediendesigner.de/"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    self.isDebugger = NO;
    
    self.featureSelectionTable.delegate = self;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [PFFacebookUtils initializeFacebook];
    
    [UIWebviewInterfaceController setWebview:self.webView];
    [self registerForLocations];
    [self registerForChannel];
    
    self.webView.scalesPageToFit = YES;
    self.webView.multipleTouchEnabled = YES;
    
    CGRect webViewFrame = self.webView.frame;
    webViewFrame.origin.x = 0;
    webViewFrame.origin.y = 0;
    self.webView.frame = webViewFrame;
    
    
    //UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    //[gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    //[self.view addGestureRecognizer:gestureRecognizer];
    [Logger setTextfield:self.debugView];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [Logger outputMessage:version withScope:@"APP"];
}

-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    FunctionTestViewController* viewCtrl = (FunctionTestViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"FunctionTest"];
    [self.navigationController pushViewController: viewCtrl animated:YES];
    /*CGRect basketTopFrame = self.webView.frame;
    self.isDebugger = !self.isDebugger;
    if(self.isDebugger)
        basketTopFrame.size.height = 0;
    else
        basketTopFrame.size.height = 960;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.webView.frame = basketTopFrame;
    }];*/
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

- (void)registerForLocations
{
    _locationCtrl = [[LocationController alloc] init];
    SocialModel *social = [[SocialModel alloc]init];
}

- (void)registerForChannel
{
    // When users indicate they are Giants fans, we subscribe them to that channel.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"HausamSee" forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    NSArray *subscribedChannels = [PFInstallation currentInstallation].channels;
    NSLog(@"Channel: %@", subscribedChannels);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onLeavingButtonPressed:(id)sender
{
    SocialModel* socialCtrl = [[SocialModel alloc] init];
    [socialCtrl getFriendsList];
    /* CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(52.445270f, 13.325877f);
     [_locationCtrl registerForRegion:coord withRadius:250];*/
}

- (IBAction)loginButtonTouchHandler:(id)sender
{
    // Send a notification to all devices subscribed to the "Giants" channel.
    /* PFPush *push = [[PFPush alloc] init];
     [push setChannel:@"HausamSee"];
     [push setMessage:@"The Giants just scored!"];
     [push sendPushInBackground];
     */// The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"friends_about_me"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"fbId"];
                    [[PFUser currentUser] saveInBackground];
                }
            }];
        } else {
            NSLog(@"User with facebook logged in!");
            //  [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        }
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"startLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finishLoad");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"startLoadingWithURL: %@", [[request URL] absoluteString]);
    if ([[[request URL] absoluteString] rangeOfString:@"native://"].location != NSNotFound)
    {
        NSString * jsCallBack = [NSString stringWithFormat:@"_callJS('%@')", [UIWebviewInterfaceController callNativeCode:[[request URL] absoluteString]]];
        [self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
		return NO;
    }
    return YES;
}

@end
