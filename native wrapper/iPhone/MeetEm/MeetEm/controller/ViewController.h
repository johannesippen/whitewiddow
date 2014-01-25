//
//  ViewController.h
//  Whitewidow
//
//  Created by Paul Schmidt on 11.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate>
+(void)writeToDebugView:(NSString*)message;
@end
