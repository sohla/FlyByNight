//
//  SOLogger.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 29/04/2015.
//  Copyright (c) 2015 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 things to log
 
 session start / end time
 
 battery level at start of session
 battery level at end of session
 
 
 */

@interface SOLogger : NSObject

+ (void)logWithString:(NSString *)msg;

@end
