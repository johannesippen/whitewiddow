//
//  ViewController.m
//  Whitewidow
//
//  Created by Paul Schmidt on 11.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
    @property IBOutlet UIWebView *webView;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://google.de"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
