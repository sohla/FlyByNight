//
//  SOFloatTransformer.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 8/06/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//
//0.3565
//0.713
#import "SOFloatTransformer.h"

@implementation SOFloatTransformer

+(NSNumber*)transformValue:(NSNumber*)val valWithPropName:(NSString*)name{
    
    SEL sel = NSSelectorFromString([name stringByAppendingString:@":"]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSNumber *uiVal = 0;
    if([SOFloatTransformer respondsToSelector:sel]){
        uiVal = [[SOFloatTransformer class] performSelector:sel withObject:val];
        
    }
    
#pragma clang diagnostic pop

    return uiVal;
}

+(NSNumber*)zoom:(NSNumber*)val{
    return [NSNumber numberWithFloat:0.5 + ([val floatValue] * 1.5f)];
}
+(NSNumber*)offset_x:(NSNumber*)val{
    return [NSNumber numberWithFloat:(([val floatValue] * 2.0f) - 1.0f) * M_PI];
}
+(NSNumber*)offset_y:(NSNumber*)val{
    return [NSNumber numberWithFloat:(([val floatValue] * 2.0f) - 1.0f) * M_PI];
}

+(NSNumber*)scroll_dx:(NSNumber*)val{
    return [NSNumber numberWithFloat:[val floatValue] * M_PI];
}
+(NSNumber*)scroll_dy:(NSNumber*)val{
    return [NSNumber numberWithFloat:[val floatValue] * M_PI];
}

+(NSNumber*)pre_time:(NSNumber*)val{
    return val;
}



@end
