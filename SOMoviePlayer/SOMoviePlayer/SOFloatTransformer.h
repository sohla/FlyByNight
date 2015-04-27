//
//  SOFloatTransformer.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 8/06/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOFloatTransformer : NSObject


+(NSNumber*)transformValue:(NSNumber*)val valWithPropName:(NSString*)name;

+(NSNumber*)zoom:(NSNumber*)val;

+(NSNumber*)offset_x:(NSNumber*)val;
+(NSNumber*)offset_y:(NSNumber*)val;

+(NSNumber*)scroll_dx:(NSNumber*)val;
+(NSNumber*)scroll_dy:(NSNumber*)val;

+(NSNumber*)pre_time:(NSNumber*)val;

+(NSNumber*)fadein_time:(NSNumber*)val;
+(NSNumber*)fadeout_time:(NSNumber*)val;


@end
