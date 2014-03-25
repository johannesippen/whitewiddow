//
//  LocationUtilsDelegate.h
//  MeetEm
//
//  Created by Paul Schmidt on 16.02.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LocationUtilsDelegate <NSObject>

-(void) bestVenueDataReceived:(NSArray*)venue withType:(NSString*)type;
-(void) foursquareNotReached;
@end
