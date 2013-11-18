//
//  Logger.m
//  Whitewidow
//
//  Created by Paul Schmidt on 15.09.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "Logger.h"
#import "ViewController.h"
#import <UIKit/UITextView.h>

@implementation Logger

static UITextView* debugview;

+(void)logMessage: (NSString*)message withScope:(NSString*)scope
{
    NSDate *date = [NSDate date];
    NSString *output = debugview.text;
    output = [output stringByAppendingString:[date description]];
    output = [output stringByAppendingString:@" ["];
    output = [output stringByAppendingString:scope];
    output = [output stringByAppendingString:@"] "];
    output = [output stringByAppendingString:message];
    output = [output stringByAppendingString:@"\n"];
    
    NSLog(@"%@", output);
    
    if(debugview != nil)
        [debugview setText:output];
}

+(void)outputMessage: (NSString*)message withScope:(NSString*)scope
{
    NSString *output = debugview.text;
    output = [output stringByAppendingString:@" ["];
    output = [output stringByAppendingString:scope];
    output = [output stringByAppendingString:@"] "];
    output = [output stringByAppendingString:message];
    output = [output stringByAppendingString:@"\n"];
    
    NSLog(@"%@", output);
    
    if(debugview != nil)
        [debugview setText:output];
}

+(void)setTextfield:(UITextView*) textView
{
    debugview = textView;
}
@end
