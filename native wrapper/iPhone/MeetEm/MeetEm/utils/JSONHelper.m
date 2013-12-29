//
//  JSONHelper.m
//  Whitewidow
//
//  Created by Paul Schmidt on 12.08.13.
//  Copyright (c) 2013 Paul Schmidt. All rights reserved.
//

#import "JSONHelper.h"

@implementation JSONHelper

+(NSString *) stringify:(PFObject *)obj
{
    return @"";
}

+(PFObject *)parseJSON:(NSData *)json
{
    /*PFObject *dataObject;
     id returnObj = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:nil];
     
     if([returnObj isKindOfClass:[NSDictionary class]])
     {
     NSDictionary *result = returnObj;
     //dataObject = [PFObject ini]
     }
     else
     {
     NSLog(@"Error: No appropriate JSON Object given!!!");
     }
     */
    return nil;
}

// Converts a given Dictionary to a JSON-like specific output
+(NSData *)convertDictionaryToJSON:(NSDictionary *)dict forSignal:(NSString *)signal
{
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    [jsonData setValue:signal forKey:@"messageType"];
    [jsonData setValue:dict forKey:@"data"];
    NSData *jsonResult = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONReadingAllowFragments error:nil];
    return jsonResult;
}

// Converts a given Dictionary to a JSON-like specific output
+(NSData *)convertArrayToJSON:(NSArray *)list forSignal:(NSString *)signal
{
    NSMutableDictionary *jsonData = [[NSMutableDictionary alloc] init];
    [jsonData setValue:signal forKey:@"messageType"];
    [jsonData setValue:list forKey:@"data"];
    NSData *jsonResult = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONReadingAllowFragments error:nil];
    return jsonResult;
}

+ (NSDate*)dateWithJSONString:(NSString*)dateStr
{
    
    return [NSDate dateWithTimeIntervalSince1970:[dateStr intValue]];
}

@end
