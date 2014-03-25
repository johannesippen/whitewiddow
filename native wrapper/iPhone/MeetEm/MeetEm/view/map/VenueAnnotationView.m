//
//  VenueAnnotationView.m
//  MeetEm
//
//  Created by Paul Schmidt on 16.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "VenueAnnotationView.h"

@implementation VenueAnnotationView

BOOL markerIsSelected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self draw];
    }
    return self;
}

- (void) draw
{
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image;
    imageView.bounds = CGRectMake(0, 0, 33, 40);
    
    NSLog(@"Marker: %@ is %i", [self.annotation title], markerIsSelected);
    
    if (markerIsSelected)
    {
        image = [UIImage imageNamed:@"icon-selectedbar"];
    }
    else
    {
        image = [UIImage imageNamed:@"icon-bar"];
    }
    self.image = image;
}


- (void)setSelected:(BOOL)selected
{
    markerIsSelected = selected;
    [self draw];
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
