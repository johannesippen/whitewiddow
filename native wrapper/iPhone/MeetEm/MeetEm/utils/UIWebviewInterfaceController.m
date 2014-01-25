//
//  UIWebviewInterfaceController.m
//  Whitewidow
//
//  Created by Paul Schmidt on 20.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "UIWebviewInterfaceController.h"
#import "ContactsModel.h"
#import "LocationController.h"
#import "Logger.h"
#import "SocialModel.h"
#import "PushController.h"
#import "EventModel.h"
#import "MapModel.h"
#import "EventViewController.h"

@interface UIWebviewInterfaceController()
@property (nonatomic) LocationController *locationController;

@end

@implementation UIWebviewInterfaceController
static UIWebView* _webView;
static UIWebviewInterfaceController* _interface;
static UIViewController* _rootController;

- (LocationController*) locationController
{
    if(_locationController == nil)
    {
        _locationController = [[LocationController alloc]init];
    }
    return _locationController;
}

+ (UIWebviewInterfaceController*) getInstance
{
    if(_interface == nil)
    {
        _interface = [[UIWebviewInterfaceController alloc] init];
    }
    return _interface;
}

+(void) setWebview:(UIWebView*) webview
{
    _webView = webview;
}

+ (NSString*)callNativeCode:(NSString *)requestString
{
    NSString* message = [requestString stringByReplacingOccurrencesOfString:@"native://" withString:@""];
    NSArray* messageComponents = [message componentsSeparatedByString:@"&"];
    NSString* messageType = [messageComponents objectAtIndex:0];
    NSString* messageParam;
    if(messageComponents.count > 1)
    {
        messageParam = [messageComponents objectAtIndex:1];
    }
    NSString* returnValue = @"";
    
    ContactsModel *contacts = [[ContactsModel alloc] init];
    SocialModel *social = [[SocialModel alloc] init];
    if([messageType rangeOfString:@"getContacts"].location != NSNotFound)
    {
        returnValue = [[NSString alloc] initWithData:[contacts getABContactsAsJSON] encoding:NSUTF8StringEncoding];
    }
    else if ([messageType rangeOfString:@"hasAccessToContacts"].location != NSNotFound)
    {
        returnValue = [[NSString alloc] initWithData:[contacts hasABPermissionAsJSON] encoding:NSUTF8StringEncoding];
    }else if ([messageType rangeOfString:@"getFBContacts"].location != NSNotFound)
    {
        [social getFriendsList];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"getConnectedFBContacts"].location != NSNotFound)
    {
        [social getFriendsListOfConnectedFriends];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"connectFB"].location != NSNotFound)
    {
        [social connect:@"Facebook"];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"inviteFBUser"].location != NSNotFound)
    {
        [social inviteFBUserById:messageParam];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"getInvitedUser"].location != NSNotFound)
    {
        [social getInvitedUser];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"getWWFriendsList"].location != NSNotFound)
    {
        [social getWWFriendsList];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"saveCurrentState"].location != NSNotFound)
    {
        [social saveCurrentState:messageParam];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"authorizeCoreLocation"].location != NSNotFound)
    {
        [[[UIWebviewInterfaceController getInstance] locationController] authorize];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"getCoreLocationAuthorizeState"].location != NSNotFound)
    {
        [[[UIWebviewInterfaceController getInstance] locationController] getAuthorizationState];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"getLocation"].location != NSNotFound)
    {
        [[[UIWebviewInterfaceController getInstance] locationController] getLocation];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"log"].location != NSNotFound)
    {
        [Logger logMessage:messageParam withScope:@"JS-LOG"];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"authorizePushNotification"].location != NSNotFound)
    {
        [PushController enablePushNotification];
        returnValue = @"true";
    }else if([messageType rangeOfString:@"createEventWithUser"].location != NSNotFound)
    {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        EventViewController* viewCtrl = (EventViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"EventView"];
        [_rootController.navigationController pushViewController: viewCtrl animated:YES];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"createEvent"].location != NSNotFound)
    {
        [EventModel createEvent:messageParam];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"attendEvent"].location != NSNotFound)
    {
        [EventModel attendEvent:messageParam];
        returnValue = @"true";
    }else if ([messageType rangeOfString:@"getEventById"].location != NSNotFound)
    {
        [EventModel getEventById:messageParam];
        returnValue = @"true";
    }else if([messageType rangeOfString:@"getUserData"].location != NSNotFound)
    {
        [social getUserData];
        returnValue = @"true";
    }else if([messageType rangeOfString:@"setInvitationState"].location != NSNotFound)
    {
        [social setInvitationState:messageParam];
        returnValue = @"true";
    }else if([messageType rangeOfString:@"showMap"].location != NSNotFound)
    {
        [MapModel showMap];
        returnValue = @"true";
    }else if([messageType rangeOfString:@"addMarker"].location != NSNotFound)
    {
        [MapModel addMarker:messageParam];
        returnValue = @"true";
    }else if([messageType rangeOfString:@"hideMap"].location != NSNotFound)
    {
        [MapModel hideMap];
        returnValue = @"true";
    }
    
    
    NSLog(@"Native return: %@", returnValue);
    return returnValue;
}

+(void) callJavascript:(NSData*)json
{
    NSString* jsCallback = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    jsCallback = [NSString stringWithFormat:@"_callJS('%@')", jsCallback];
    [Logger logMessage:jsCallback withScope:@"JS-CALLBACK"];
    [_webView stringByEvaluatingJavaScriptFromString:jsCallback];
}

+(void) setRootController:(UIViewController*)controller
{
    _rootController = controller;
}

@end
