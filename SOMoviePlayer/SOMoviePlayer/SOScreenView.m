//
//  SOScreenView.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 10/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOScreenView.h"

@interface SOScreenView ()

@property (strong, nonatomic) UIView *progressView;

@end
@interface SOScreenView ()


-(UIColor*)randomColor;

@end


@implementation SOScreenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        CGRect rect  = {0.0f,0.0f,frame.size.width,2.0f};
        _progressView = [[UIView alloc] initWithFrame:rect];
        
        [self.progressView setBackgroundColor:[UIColor redColor] ];
        
        [self addSubview:self.progressView];


    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    if(YES){
        
        CGContextRef    context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 3.0f);
        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);

        CGPoint topLeft = {0.0f, 0.0f};
        CGPoint bottomRight = {self.bounds.size.width, self.bounds.size.height};
        
        CGContextMoveToPoint(context, topLeft.x, topLeft.y);
        CGContextAddLineToPoint(context, bottomRight.x, bottomRight.y);
        
        CGContextMoveToPoint(context, topLeft.x, bottomRight.y);
        CGContextAddLineToPoint(context, bottomRight.x, topLeft.y);
        
        CGContextStrokePath(context);
    }
}

-(UIColor*)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
}

-(void)setProgress:(float)progress{
   
    CGRect rect  = {0.0f,self.frame.size.height,self.frame.size.width * progress,2.0f};
    [self.progressView setFrame:rect];
}


@end
