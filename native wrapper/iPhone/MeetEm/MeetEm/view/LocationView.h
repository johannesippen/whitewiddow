//
//  LocationView.h
//  MeetEm
//
//  Created by Paul Schmidt on 15.02.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationView : UIView

-(void) updateLocation:(NSString*)location;
-(void) updateDescription:(NSString*)description;
-(void) updateDistance:(NSString*)distance;

@end
