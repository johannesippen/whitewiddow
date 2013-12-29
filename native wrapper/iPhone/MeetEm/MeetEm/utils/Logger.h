//
//  Logger.h
//  MeetEm
//
//  Created by Paul Schmidt on 29.12.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject
+(void)logMessage: (NSString*)message withScope:(NSString*)scope;
+(void)outputMessage: (NSString*)message withScope:(NSString*)scope;
+(void)setTextfield:(UITextView*) textView;
@end
