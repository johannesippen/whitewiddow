//
//  UIWebviewInterfaceController.h
//  Whitewidow
//
//  Created by Paul Schmidt on 20.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIWebviewInterfaceController : NSObject
+(void) setWebview:(UIWebView*) webview;
+(NSString *)callNativeCode:(NSString*) requestString;
+(void) callJavascript:(NSData*)json;
+(void) setRootController:(UIViewController*)controller;
@end
