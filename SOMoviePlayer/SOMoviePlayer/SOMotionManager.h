//
//  SOMotionManager.h
//  SOMoviePlayer
//
//  Created by Stephen OHara on 25/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface SOMotionManager : NSObject

+ (SOMotionManager*)sharedManager;


-(void)buildMotionManager;
-(void)destroyMotionManager;

-(float)valueForKey:(NSString*)key;

-(void)reset;
@end
