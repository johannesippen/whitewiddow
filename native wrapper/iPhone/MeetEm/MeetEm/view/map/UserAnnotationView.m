//
//  UserAnnotationView.m
//  MeetEm
//
//  Created by Paul Schmidt on 16.03.14.
//  Copyright (c) 2014 Paul Schmidt. All rights reserved.
//

#import "UserAnnotationView.h"
#import "UserMarker.h"

@implementation UserAnnotationView

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



- (void)draw
{
    // Drawing code
    UIImageView *imageView = [[UIImageView alloc] init];
    UIImage *image;
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(-28,-28,56,56)];
    switch ([(UserMarker*)self.annotation availability])
    {
         case 0:
             [circleView.layer setBorderColor:[[UIColor colorWithRed:0 green:.54 blue:1 alpha:1] CGColor]];
             [circleView.layer setBorderWidth:3];
             circleView.layer.cornerRadius = 28;
             [self insertSubview:circleView atIndex:0];
         break;
         
         case 1:
             [circleView.layer setBorderColor:[[UIColor colorWithRed:0.5 green:.5 blue:.5 alpha:1] CGColor]];
             [circleView.layer setBorderWidth:3];
             circleView.layer.cornerRadius = 28;
             [self insertSubview:circleView atIndex:0];
         break;
         
         default:
         break;
    }
     
     NSString *imageUrl = @"https://graph.facebook.com/";
     imageUrl = [imageUrl stringByAppendingString:[self.annotation title]];
     imageUrl = [imageUrl stringByAppendingString:@"/picture?width=90&height=90&type=large"];
     
     
     
     imageView.bounds = CGRectMake(0, 0, 45, 45);
     image = [self getRoundedRectImageFromImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]] onReferenceView:imageView withCornerRadius: 22.5];
     
     
     self.image = [UIImage imageWithData:nil];
     imageView.image = image;
     [self addSubview:imageView];
}

- (UIImage *)getRoundedRectImageFromImage :(UIImage *)image onReferenceView :(UIImageView*)imageView withCornerRadius :(float)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:imageView.bounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}


@end
