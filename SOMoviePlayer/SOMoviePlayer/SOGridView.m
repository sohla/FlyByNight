//
//  SOGridView.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 5/07/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import "SOGridView.h"

@implementation SOGridView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    CGContextRef    context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    
    CGPoint topLeft = {0.0f, 0.0f};
    CGPoint bottomRight = {self.bounds.size.width, self.bounds.size.height};
    
    CGContextMoveToPoint(context, topLeft.x, topLeft.y);
    CGContextAddLineToPoint(context, bottomRight.x, bottomRight.y);
    
    CGContextMoveToPoint(context, topLeft.x, bottomRight.y);
    CGContextAddLineToPoint(context, bottomRight.x, topLeft.y);
    
    CGContextStrokePath(context);
}


@end
