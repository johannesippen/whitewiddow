//
//  LocationView.m
//  MeetEm
//
//  Created by Paul Schmidt on 15.02.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "LocationView.h"

@implementation LocationView

UILabel* locationLabel;
UILabel* descriptionLabel;
UILabel* distanceLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // location
        locationLabel = [[UILabel alloc] init];
        locationLabel.frame = CGRectMake(28, 35, 272, 21);
        locationLabel.textColor = [UIColor colorWithRed:0 green:.54 blue:1 alpha:1];
        [locationLabel setFont:[UIFont fontWithName:@"MissionGothic-Regular" size:18]];
        locationLabel.text = @"Test2";
        [self addSubview:locationLabel];
        
        // description
        descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(28, 55, 272, 21);
        descriptionLabel.textColor = [UIColor colorWithRed:0.2 green:.2 blue:.2 alpha:1];
        [descriptionLabel setFont:[UIFont fontWithName:@"MissionGothic-Regular" size:14]];
        [self addSubview:descriptionLabel];
        
        // distance
        distanceLabel = [[UILabel alloc] init];
        distanceLabel.frame = CGRectMake(28, 75, 272, 21);
        distanceLabel.textColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1];
        [distanceLabel setFont:[UIFont fontWithName:@"MissionGothic-Regular" size:14]];
        [self addSubview:distanceLabel];
    }
    return self;
}

-(void) updateLocation:(NSString*)location
{
    [locationLabel performSelectorOnMainThread:@selector(setText:) withObject:location waitUntilDone:YES];
    //locationLabel.text = location;
}

-(void) updateDescription:(NSString*)description
{
    description = @"Bar & Café";
    [descriptionLabel performSelectorOnMainThread:@selector(setText:) withObject:description waitUntilDone:YES];
}

-(void) updateDistance:(NSString*)distance
{
    [distanceLabel performSelectorOnMainThread:@selector(setText:) withObject:distance waitUntilDone:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
