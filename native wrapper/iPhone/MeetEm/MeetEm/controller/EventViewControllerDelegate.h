//
//  EventViewControllerDelegate.h
//  MeetEm
//
//  Created by Paul Schmidt on 26.02.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventViewControllerDelegate <NSObject>
-(void) venueDataReceived:(NSDictionary*) venues;
-(void) eventSaved;
@end
