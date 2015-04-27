//
//  SOCueModel.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 31/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOCueModel.h"

@implementation SOCueModel



//• transformValueForKey

-(float)transformValueForKey:(NSString*)key{

    NSString *formula = @"((val * 2.0) - 1.0) * pi";
    
    NSExpression *expr = [NSExpression expressionWithFormat:formula];
    NSDictionary *object = @{
                             @"val": @0.5,
                             @"pi": @(M_PI)
                             };
    
    
    
    float result = [[expr expressionValueWithObject:object context:nil] floatValue];
    
    DLog(@"%f",result);

    return result;
    
}


//• do we save 0..1 or transformed value?
@end
