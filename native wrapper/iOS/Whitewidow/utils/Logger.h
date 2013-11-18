//
//  Logger.h
//  Whitewidow
//
//  Created by Paul Schmidt on 15.09.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject
+(void)logMessage: (NSString*)message withScope:(NSString*)scope;
+(void)outputMessage: (NSString*)message withScope:(NSString*)scope;
+(void)setTextfield:(UITextView*) textView;
@end
