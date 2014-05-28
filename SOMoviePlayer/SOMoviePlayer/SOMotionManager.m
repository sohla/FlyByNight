//
//  SOMotionManager.m
//  SOMoviePlayer
//
//  Created by Stephen OHara on 25/05/2014.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOMotionManager.h"

@interface SOMotionManager ()

@property (strong, nonatomic) CMMotionManager           *motionManager;

@end


@implementation SOMotionManager


+ (SOMotionManager*)sharedManager{
    
    static SOMotionManager *_sharedManager;
    if(!_sharedManager) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedManager = [[super allocWithZone:nil] init];
        });
    }
    
    return _sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    return [self sharedManager];
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Motion
-(void)buildMotionManager{
    
    if(self.motionManager == nil){
        _motionManager = [[CMMotionManager alloc] init];
    }
    
    self.motionManager.deviceMotionUpdateInterval = 0.02;  // 50 Hz
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
    
    
}

-(void)destroyMotionManager{

    if(self.motionManager!=nil)
        self.motionManager = nil;
    
}

-(void)reset{
    
    [self destroyMotionManager];
    [self buildMotionManager];
}

-(float)valueForKey:(NSString*)key{
    
    if([key isEqualToString:@"roll"]){
        return self.motionManager.deviceMotion.attitude.roll;
    }
    if([key isEqualToString:@"pitch"]){
        return self.motionManager.deviceMotion.attitude.pitch;
    }
    if([key isEqualToString:@"yaw"]){
        return self.motionManager.deviceMotion.attitude.yaw;
    }
    if([key isEqualToString:@"heading"]){
        return self.motionManager.deviceMotion.magneticField.field.y;
    }
    
    
    return 0.0f;
    
}
@end
