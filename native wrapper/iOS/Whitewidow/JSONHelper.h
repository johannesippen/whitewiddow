//
//  JSONHelper.h
//  Whitewidow
//
//  Created by Paul Schmidt on 12.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface JSONHelper : NSObject

+(PFObject *) parseJSON:(NSString *) json;
+(NSString *) stringify: (PFObject *) obj;
+(NSData *) convertDictionaryToJSON: (NSDictionary *) dict forSignal: (NSString *) signal;
+(NSData *) convertArrayToJSON:(NSArray *)list forSignal:(NSString *)signal;
+ (NSDate*)dateWithJSONString:(NSString*)dateStr;

@end
